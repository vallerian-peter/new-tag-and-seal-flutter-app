# Auto-Login Flow Analysis

## Current Implementation

### Flow Path
```
App Start
    ↓
SplashScreen (3 seconds delay)
    ↓
GetStartedScreen (_checkAutoLogin)
    ↓
AuthProvider.tryAutoLogin()
    ↓
AuthRepository.isAuthenticated() + getStoredUserData()
    ↓
[Success] → Navigate to HomeScreen
[Failed] → Show GetStartedScreen UI
```

---

## Analysis of Auto-Login Implementation

### ✅ What's Working

1. **GetStartedScreen checks auto-login** (lines 34-64)
   - Calls `authProvider.tryAutoLogin()` on initState
   - Shows loading indicator while checking
   - Navigates to HomeScreen on success

2. **AuthProvider.tryAutoLogin()** (lines 374-411 in auth_provider.dart)
   - Checks if user is authenticated
   - Gets stored user data
   - Updates state with user data
   - Returns true/false

3. **AuthRepository.isAuthenticated()** (lines 194-216 in auth_repositoy.dart)
   - Checks SharedPreferences flag
   - Verifies essential data exists in secure storage
   - Returns boolean

---

## ⚠️ Issues Found

### Issue 1: Password Not Used for Actual Login

**Problem:**
The auto-login flow (`tryAutoLogin()`) only retrieves stored data - it doesn't actually re-authenticate with the server.

**Current Flow:**
```dart
// In AuthProvider.tryAutoLogin()
final isAuthenticated = await _authRepository.isAuthenticated();
final storedData = await _authRepository.getStoredUserData();
// Just loads stored data - doesn't verify token with server
```

**Why This is a Problem:**
- If token expires, user won't know until they try to make an API call
- No token refresh mechanism
- User might be logged out unexpectedly

**Should We:**
- Actually login again when token expires?
- Or just load stored data and handle token expiry on API calls?

---

### Issue 2: Token Validity Check Only in LoginPage

**Problem:**
The token validity check (`_isTokenValid()`) only exists in LoginPage, not in the auto-login flow.

**Current Implementation:**
```dart
// LoginPage._checkStoredCredentials() - HAS token check
final isTokenValid = _isTokenValid(token);
if (isTokenValid) {
  // Navigate to HomeScreen
} else {
  // Auto-login
}

// GetStartedScreen._checkAutoLogin() - NO token check
final autoLoginSuccess = await authProvider.tryAutoLogin();
// Always proceeds without checking token validity
```

**Impact:**
- Auto-login might succeed even with expired token
- User will be logged out on first API call

---

### Issue 3: Inconsistent Auto-Login Logic

**Problem:**
Two different auto-login flows:

1. **LoginPage auto-login** (`_checkStoredCredentials()`)
   - Checks token validity
   - Auto-logins if token expired
   - Shows "User Data Available" banner

2. **GetStartedScreen auto-login** (`_checkAutoLogin()`)
   - No token validity check
   - Just loads stored data
   - No auto-login attempt

**Which one should we use?**

---

### Issue 4: Password Stored but Not Used for Re-authentication

**Problem:**
Password is saved in secure storage (`storeUserData()` line 422 in auth_repositoy.dart) but:
- Not used in `tryAutoLogin()` to re-authenticate
- Only used in LoginPage for auto-login when token expires

**Question:**
Should auto-login actually call the login API again?

---

## Recommendations

### Option 1: Load Stored Data Only (Current Approach)

**Pros:**
- Fast
- No network calls
- Simple implementation

**Cons:**
- Token might be expired
- User logged out unexpectedly
- No verification with server

**Implementation:**
- Keep current implementation
- Handle token expiry on API calls
- Show login screen if token invalid

---

### Option 2: Verify Token with Server

**Pros:**
- Token validity verified
- Better user experience
- No unexpected logouts

**Cons:**
- Network call on every app start
- Slower startup
- Might fail if offline

**Implementation:**
```dart
Future<bool> tryAutoLogin() async {
  // Check if user is authenticated locally
  final isAuthenticated = await _authRepository.isAuthenticated();
  if (!isAuthenticated) return false;
  
  // Get stored credentials
  final credentials = await _authRepository.getSavedCredentials();
  if (credentials == null) return false;
  
  // Check token validity
  final token = await _authRepository.getToken();
  if (!_isTokenValid(token)) {
    // Token expired - re-authenticate
    return await login(username: credentials['username'], password: credentials['password']);
  }
  
  // Token valid - load stored data
  final storedData = await _authRepository.getStoredUserData();
  _currentUser = storedData['user'];
  _isAuthenticated = true;
  notifyListeners();
  return true;
}
```

---

### Option 3: Hybrid Approach (Recommended)

**Pros:**
- Fast when token valid
- Auto-login when token expired
- Best user experience

**Cons:**
- More complex logic
- Network call only when needed

**Implementation:**
```dart
Future<bool> tryAutoLogin() async {
  try {
    // 1. Check if stored credentials exist
    final credentials = await _authRepository.getSavedCredentials();
    if (credentials == null) return false;
    
    // 2. Check token validity
    final token = await _authRepository.getToken();
    if (token != null && _isTokenValid(token)) {
      // Token valid - load stored data (fast path)
      final storedData = await _authRepository.getStoredUserData();
      if (storedData != null) {
        _currentUser = storedData['user'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }
    
    // 3. Token expired or invalid - re-authenticate (slow path)
    return await login(
      username: credentials['username'],
      password: credentials['password'],
    );
    
  } catch (e) {
    return false;
  }
}

bool _isTokenValid(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded) as Map<String, dynamic>;
    
    if (payloadMap.containsKey('exp')) {
      final exp = payloadMap['exp'] as int;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiryDate.isAfter(DateTime.now());
    }
    
    return true;
  } catch (e) {
    return false;
  }
}
```

---

## Testing Scenarios

### Scenario 1: Fresh Install
1. App launches
2. No stored credentials
3. Shows GetStartedScreen ✅

### Scenario 2: Valid Token
1. App launches
2. Finds stored credentials
3. Token is valid (not expired)
4. Loads stored data
5. Navigates to HomeScreen ✅

### Scenario 3: Expired Token
1. App launches
2. Finds stored credentials
3. Token is expired
4. **Current:** Might fail silently or load invalid data ❌
5. **Recommended:** Auto-login with stored credentials ✅

### Scenario 4: Invalid Credentials
1. App launches
2. Finds stored credentials
3. Attempts auto-login
4. Server rejects credentials
5. Shows GetStartedScreen ✅

### Scenario 5: Network Offline
1. App launches
2. Finds stored credentials
3. Token is expired
4. Attempts auto-login
5. Network request fails
6. **Current:** Shows GetStartedScreen ❌
7. **Recommended:** Use cached data if offline ✅

---

## Summary

### Current State
- ✅ Auto-login checks on app startup
- ✅ Password stored for auto-login
- ⚠️ No token validity check in auto-login flow
- ⚠️ No actual re-authentication when token expires
- ⚠️ Inconsistent logic between LoginPage and GetStartedScreen

### Recommended Changes
1. Add token validity check to `tryAutoLogin()`
2. Re-authenticate when token expired
3. Handle offline scenarios
4. Consistent auto-login logic across all entry points

### Questions to Answer
1. Should we verify token with server on startup?
2. Should we auto-login when token expires?
3. What should happen when offline and token expired?
4. Should we keep password in secure storage?

