# Authentication Flow Explanation

## Complete Flow from LoginPage to AuthRepository

### Visual Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        LoginPage (UI)                        │
│  - User enters credentials                                  │
│  - Calls authProvider.login()                               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     AuthProvider (State)                     │
│  - Shows loading dialog                                     │
│  - Calls authRepository.login()                             │
│  - Updates state (currentUser, isAuthenticated)             │
│  - Handles errors with error dialogs                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  AuthRepository (Data Layer)                 │
│  - Calls AuthService.login() (API call)                     │
│  - Saves token to secure storage                            │
│  - Saves credentials (username, password)                   │
│  - Saves user data to SharedPreferences                     │
│  - Sets logged in status                                    │
│  - Returns data to AuthProvider                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    AuthService (API Layer)                   │
│  - Makes HTTP POST to /api/farmer/login                     │
│  - Sends username and password                              │
│  - Returns user data + token                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Flow

### 1. **LoginPage (_handleLogin method)**
**File:** `login_screen.dart` (lines 205-263)

**What happens:**
```dart
// User taps "Login" button
_handleLogin() {
  // 1. Validate form
  if (_formKey.currentState!.validate()) {
    
    // 2. Get AuthProvider instance
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 3. Call AuthProvider's login method
    final success = await authProvider.login(
      context: context,
      username: _emailController.text,
      password: _passwordController.text,
    );
    
    // 4. Navigate to HomeScreen on success
    if (success) {
      Navigator.pushReplacement(context, HomeScreen());
    }
  }
}
```

**Key Points:**
- Validates the form before proceeding
- Calls `AuthProvider.login()` with username and password
- Navigates to `HomeScreen` on success
- Shows error dialog on failure

---

### 2. **AuthProvider (login method)**
**File:** `auth_provider.dart` (lines 165-257)

**What happens:**
```dart
Future<bool> login({required String username, required String password}) async {
  // Step 1: Show loading dialog
  AlertDialogs.showLoading(context: context, ...);
  
  // Step 2: Set loading state
  _isLoggingIn = true;
  notifyListeners();
  
  try {
    // Step 3: Call AuthRepository to login
    final loginData = await _authRepository.login(
      username: username,
      password: password,
    );
    
    // Step 4: Extract data from response
    final user = loginData['user'];
    final profile = loginData['profile'];
    final accessToken = loginData['accessToken'];
    final tokenType = loginData['tokenType'];
    
    // Step 5: Update state
    _currentUser = user;
    _isAuthenticated = true;
    
    // Step 6: Store all data using AuthRepository
    await _authRepository.storeUserData(
      userId: user['id'],
      username: user['username'],
      email: user['email'],
      role: user['role'],
      roleId: user['roleId'],
      firstname: user['firstname'],
      surname: user['surname'],
      phone1: user['phone1'],
      physicalAddress: user['physicalAddress'],
      dateOfBirth: user['dateOfBirth'],
      gender: user['gender'],
      accessToken: accessToken,
      tokenType: tokenType,
      password: password,  // Saves password for auto-login
      profile: profile,
    );
    
    // Step 7: Load farmer data if user is a farmer
    if (_currentUser?['role'] == 'farmer') {
      _currentFarmer = await _authRepository.getCurrentFarmer();
    }
    
    notifyListeners();
    return true;
    
  } catch (e) {
    // Handle error - show error dialog
    _errorMessage = e.toString();
    _isLoggingIn = false;
    notifyListeners();
    
    AlertDialogs.showError(context: context, ...);
    return false;
  }
}
```

**Key Points:**
- Shows loading dialog while processing
- Calls `AuthRepository.login()` to make API call
- Stores all user data using `AuthRepository.storeUserData()`
- Loads farmer-specific data if user is a farmer
- Updates state and notifies listeners
- Handles errors with error dialogs

---

### 3. **AuthRepository (login method)**
**File:** `auth_repositoy.dart` (lines 128-165)

**What happens:**
```dart
Future<Map<String, dynamic>> login({
  required String username,
  required String password,
}) async {
  try {
    // Step 1: Call AuthService to make API request
    final response = await AuthService.login(
      username: username,
      password: password,
    );
    
    // Step 2: Extract data from response
    final data = response['data'] as Map<String, dynamic>;
    final token = data['accessToken'] as String;
    final userData = data['user'] as Map<String, dynamic>;
    
    // Step 3: Save authentication data locally
    await saveToken(token);                                    // Save token to secure storage
    await saveCredentials(username: username, password: password); // Save credentials
    await _saveUserData(userData);                             // Save user data to SharedPreferences
    await _setLoggedInStatus(true);                            // Set logged in flag
    
    // Step 4: If user is a farmer, save farmer data
    if (userData['role'] == 'farmer' && data.containsKey('farmer')) {
      await _saveFarmerData(data['farmer'] as Map<String, dynamic>);
    }
    
    // Step 5: Return complete login data
    return data;
    
  } catch (e) {
    throw Exception('Repository: Failed to login - $e');
  }
}
```

**Key Points:**
- Calls `AuthService.login()` to make HTTP request
- Saves token to secure storage (`saveToken()`)
- Saves credentials to secure storage (`saveCredentials()`)
- Saves user data to SharedPreferences (`_saveUserData()`)
- Sets logged in status (`_setLoggedInStatus()`)
- Saves farmer data if applicable
- Returns complete data to AuthProvider

---

### 4. **AuthService (login method)**
**File:** `auth_service.dart` (lines 170-218)

**What happens:**
```dart
static Future<Map<String, dynamic>> login({
  required String username,
  required String password,
}) async {
  try {
    // Step 1: Build headers
    final headers = await _buildHeaders();
    
    // Step 2: Prepare login data
    final loginData = {
      'username': username,
      'password': password,
    };
    
    // Step 3: Make HTTP POST request
    final response = await http.post(
      Uri.parse(ApiEndpoints.farmerLogin),
      headers: headers,
      body: jsonEncode(loginData),
    );
    
    // Step 4: Parse response
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Step 5: Check response status
    if (response.statusCode == 200) {
      if (responseData['status'] == true) {
        return responseData;  // Success - return data
      } else {
        throw Exception('Login failed');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
    
  } catch (e) {
    throw Exception('Failed to login: $e');
  }
}
```

**Key Points:**
- Makes HTTP POST request to `/api/farmer/login`
- Sends username and password in request body
- Returns user data + token on success
- Throws exceptions on failure (invalid credentials, server errors, etc.)

---

## Data Storage Breakdown

### Secure Storage (FlutterSecureStorage)
Stores sensitive data with encryption:
```dart
// Keys used (from auth_repositoy.dart):
- 'auth_token'           // Access token
- 'saved_username'       // Username for auto-login
- 'saved_password'       // Password for auto-login
- 'userId'               // User ID
- 'username'             // Username
- 'email'                // Email
- 'role'                 // User role
- 'roleId'               // Role ID
- 'firstname'            // First name
- 'surname'              // Surname
- 'phone1'               // Phone number
- 'physicalAddress'      // Physical address
- 'dateOfBirth'          // Date of birth
- 'gender'               // Gender
- 'accessToken'          // Access token (duplicate)
- 'tokenType'            // Token type (Bearer)
- 'password'             // Password (for auto-login)
- 'profile'              // Profile data (JSON string)
```

### SharedPreferences
Stores non-sensitive data:
```dart
// Keys used:
- 'user_data'            // User data JSON
- 'farmer_data'          // Farmer data JSON
- 'is_logged_in'         // Boolean flag
```

---

## Auto-Login Flow

### LoginPage (_checkStoredCredentials method)
**File:** `login_screen.dart` (lines 55-121)

**What happens:**
```dart
Future<void> _checkStoredCredentials() async {
  // 1. Read stored credentials from secure storage
  final email = await _secureStorage.read(key: 'email');
  final password = await _secureStorage.read(key: 'password');
  final token = await _secureStorage.read(key: 'accessToken');
  
  // 2. Check if all required data is present
  final hasAllData = email != null && password != null && token != null;
  
  if (hasAllData) {
    // 3. Check if token is valid (not expired)
    final isTokenValid = _isTokenValid(token);
    
    if (isTokenValid) {
      // Scenario 1: Valid token → Navigate directly to HomeScreen
      Navigator.pushReplacement(context, HomeScreen());
    } else {
      // Scenario 2: Expired token → Auto-login to get new token
      _emailController.text = email;
      _passwordController.text = password;
      await _performAutoLogin(email, password);
    }
  }
}
```

**Scenarios:**
1. **Valid token exists** → Navigate directly to HomeScreen
2. **Expired token** → Auto-login to get new token
3. **No stored data** → Show login form

---

## Storage Methods Used

### `storeUserData()` method
**File:** `auth_repositoy.dart` (lines 390-439)

Stores all user data from login response:
```dart
Future<void> storeUserData({
  required String userId,
  required String username,
  required String email,
  required String role,
  required String roleId,
  required String firstname,
  required String surname,
  required String phone1,
  required String physicalAddress,
  required String dateOfBirth,
  required String gender,
  required String accessToken,
  required String tokenType,
  required String password,
  dynamic profile,
}) async {
  // Store all data in secure storage (camelCase keys)
  await _secureStorage.write(key: 'userId', value: userId);
  await _secureStorage.write(key: 'username', value: username);
  await _secureStorage.write(key: 'email', value: email);
  // ... stores all fields
  
  // Store profile as JSON
  if (profile != null) {
    final profileJson = jsonEncode(profile);
    await _secureStorage.write(key: 'profile', value: profileJson);
  }
  
  // Set logged in status
  await _prefs!.setBool(_isLoggedInKey, true);
}
```

---

## Authentication Check

### `isAuthenticated()` method
**File:** `auth_repositoy.dart` (lines 194-216)

Checks if user is authenticated:
```dart
Future<bool> isAuthenticated() async {
  // 1. Check SharedPreferences flag
  final isLoggedIn = _prefs!.getBool(_isLoggedInKey) ?? false;
  
  // 2. Check essential user data in secure storage
  final userId = await _secureStorage.read(key: 'userId');
  final username = await _secureStorage.read(key: 'username');
  final accessToken = await _secureStorage.read(key: 'accessToken');
  
  // 3. User is authenticated if:
  //    - SharedPreferences says logged in AND
  //    - Essential user data exists
  return isLoggedIn && 
         userId != null && userId.isNotEmpty &&
         username != null && username.isNotEmpty &&
         accessToken != null && accessToken.isNotEmpty;
}
```

---

## Summary

### Key Takeaways:
1. **Separation of Concerns**: Each layer has a specific responsibility
   - UI Layer (LoginPage): User interaction
   - State Layer (AuthProvider): State management and error handling
   - Data Layer (AuthRepository): Data storage and retrieval
   - API Layer (AuthService): HTTP communication

2. **Data Persistence**: Multiple storage methods
   - Secure Storage: Sensitive data (tokens, passwords)
   - SharedPreferences: Non-sensitive data (user info, flags)

3. **Error Handling**: Errors bubble up from API to UI
   - AuthService throws exceptions
   - AuthRepository catches and re-throws
   - AuthProvider catches and shows error dialogs

4. **Auto-Login**: Automatic login support
   - Stores credentials securely
   - Checks token validity
   - Auto-login when token expires

5. **State Management**: Provider pattern
   - AuthProvider manages authentication state
   - Notifies listeners on state changes
   - Provides loading states for UI

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER ACTION                          │
│              User enters credentials + taps Login           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    LoginPage._handleLogin()                  │
│  • Validates form                                           │
│  • Calls authProvider.login()                               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    AuthProvider.login()                      │
│  • Shows loading dialog                                      │
│  • Calls authRepository.login()                             │
│  • Updates state (_currentUser, _isAuthenticated)            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  AuthRepository.login()                      │
│  • Calls AuthService.login()                                │
│  • Saves token to secure storage                            │
│  • Saves credentials to secure storage                      │
│  • Saves user data to SharedPreferences                     │
│  • Sets logged in status                                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    AuthService.login()                       │
│  • Makes HTTP POST to /api/farmer/login                     │
│  • Sends username + password                                │
│  • Returns user data + token                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                        Backend API                           │
│  • Validates credentials                                    │
│  • Returns user data + JWT token                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                    [Response flows back]
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              AuthProvider receives success                   │
│  • Closes loading dialog                                    │
│  • Returns true                                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  LoginPage receives success                  │
│  • Navigates to HomeScreen                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Notes

- The password is saved in secure storage for auto-login functionality
- Token validity is checked on app startup using JWT expiration
- All sensitive data uses encrypted secure storage
- Error handling happens at multiple levels with user-friendly messages
- State is managed using Provider pattern for reactive UI updates

