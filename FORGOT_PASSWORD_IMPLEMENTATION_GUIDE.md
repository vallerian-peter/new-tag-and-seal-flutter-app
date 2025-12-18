# Forgot Password Implementation Guide

## ✅ Completed

### Backend (Laravel)
1. ✅ Created `otp_verifications` table migration
2. ✅ Created `OtpVerification` model with helper methods
3. ✅ Added `sendOtp()` method to AuthController
4. ✅ Added `resetPassword()` method to AuthController
5. ✅ Integrated BrevoEmailService for sending OTP emails
6. ✅ Added API routes:
   - `POST /api/auth/forgot-password/send-otp`
   - `POST /api/auth/forgot-password/reset-password`

### Frontend (Flutter) - UI
1. ✅ Created `/forgot_password/forgot_password_input_screen.dart`
2. ✅ Created `/forgot_password/otp_verification_screen.dart`
3. ✅ Created `/forgot_password/reset_password_screen.dart`
4. ✅ Bottom sheet selector already exists (`forgot_password_bottom_sheet.dart`)
5. ✅ Added API endpoints to `endpoints.dart`
6. ✅ Added `sendOtp()` and `resetPassword()` to AuthService

## ❌ Remaining Tasks

### 1. Add Repository Methods
**File:** `/lib/features/auth/data/local/auth_repositoy.dart`

Add these methods after the `updateProfile` method:

```dart
/// Send OTP for password reset
Future<Map<String, dynamic>> sendOtp({
  String? email,
  String? phone,
}) async {
  await _initPrefs();
  return await AuthService.sendOtp(email: email, phone: phone);
}

/// Reset password with OTP
Future<Map<String, dynamic>> resetPassword({
  String? email,
  String? phone,
  required String otp,
  required String newPassword,
}) async {
  await _initPrefs();
  return await AuthService.resetPassword(
    email: email,
    phone: phone,
    otp: otp,
    newPassword: newPassword,
  );
}
```

### 2. Add Provider Methods
**File:** `/lib/features/auth/presentation/provider/auth_provider.dart`

Add these methods before the closing brace:

```dart
// ==========================================================================
// Forgot Password
// ==========================================================================

/// Send OTP for password reset
Future<bool> sendOtp({
  String? email,
  String? phone,
}) async {
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _authRepository.sendOtp(
      email: email,
      phone: phone,
    );

    if (response['status'] == true) {
      return true;
    } else {
      _errorMessage = response['message'] ?? 'Failed to send OTP';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    return false;
  }
}

/// Reset password with OTP
Future<bool> resetPassword({
  String? email,
  String? phone,
  required String otp,
  required String newPassword,
}) async {
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _authRepository.resetPassword(
      email: email,
      phone: phone,
      otp: otp,
      newPassword: newPassword,
    );

    if (response['status'] == true) {
      return true;
    } else {
      _errorMessage = response['message'] ?? 'Failed to reset password';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    return false;
  }
}
```

### 3. Add Missing Localization Strings
**Files:** 
- `/lib/l10n/app_en.arb`
- `/lib/l10n/app_sw.arb`

Add these entries:

```json
{
  "forgotPassword": "Forgot Password?",
  "enterYourEmail": "Enter Your Email",
  "enterYourPhone": "Enter Your Phone Number",
  "otpWillBeSentToEmail": "We'll send a 6-digit OTP code to your email address",
  "otpWillBeSentToPhone": "We'll send a 6-digit OTP code to your phone number",
  "sendOtp": "Send OTP",
  "otpExpiresIn10Minutes": "OTP code expires in 10 minutes",
  "failedToSendOtp": "Failed to send OTP",
  "verifyOtp": "Verify OTP",
  "enterOtpCode": "Enter OTP Code",
  "otpSentTo": "OTP sent to",
  "verify": "Verify",
  "resendOtp": "Resend OTP",
  "pleaseEnterCompleteOtp": "Please enter complete 6-digit OTP",
  "otpResentSuccessfully": "OTP resent successfully",
  "failedToResendOtp": "Failed to resend OTP",
  "resetPassword": "Reset Password",
  "createNewPassword": "Create New Password",
  "passwordMustBeAtLeast8Characters": "Password must be at least 8 characters",
  "newPassword": "New Password",
  "enterNewPassword": "Enter new password",
  "pleaseEnterNewPassword": "Please enter new password",
  "confirmPassword": "Confirm Password",
  "enterConfirmPassword": "Re-enter password",
  "pleaseConfirmPassword": "Please confirm your password",
  "passwordsDoNotMatch": "Passwords do not match",
  "passwordResetSuccessfully": "Password reset successfully! You can now login with your new password.",
  "failedToResetPassword": "Failed to reset password",
  "pleaseEnterEmail": "Please enter your email",
  "pleaseEnterValidEmail": "Please enter a valid email",
  "pleaseEnterPhone": "Please enter your phone number",
  "pleaseEnterValidPhone": "Please enter a valid phone number"
}
```

### 4. Add Forgot Password Link to Login Screens

**File:** `/lib/features/auth/presentation/login/login_screen.dart`

After the login button, add:

```dart
const SizedBox(height: 16),
Center(
  child: TextButton(
    onPressed: () async {
      final recoveryMethod = await ForgotPasswordBottomSheet.show(context);
      if (recoveryMethod != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordInputScreen(
              recoveryMethod: recoveryMethod,
            ),
          ),
        );
      }
    },
    child: Text(
      l10n.forgotPassword,
      style: TextStyle(
        color: Constants.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
```

**File:** `/lib/features/auth/presentation/login/extension_officer_login_screen.dart`

Add the same forgot password link after the login button.

### 5. Fix CustomTextField to Support obscureText

**File:** `/lib/core/components/custom_text_field.dart`

Ensure the `CustomTextField` widget has an `obscureText` parameter. If not, add it:

```dart
final bool obscureText;

// In constructor:
this.obscureText = false,

// In TextField:
obscureText: obscureText,
```

## Testing Checklist

Once all changes are made:

1. [ ] Run `flutter pub get`
2. [ ] Run backend migration: `php artisan migrate`
3. [ ] Test email OTP flow
4. [ ] Test phone OTP flow
5. [ ] Test OTP expiry (10 minutes)
6. [ ] Test resend OTP
7. [ ] Test password reset
8. [ ] Test login with new password

## API Endpoints

### Send OTP
```
POST /api/auth/forgot-password/send-otp
Body: { "email": "user@example.com" } OR { "phone": "+255712345678" }
Response: { "status": true, "message": "OTP sent successfully", "data": { "expiresAt": "..." } }
```

### Reset Password
```
POST /api/auth/forgot-password/reset-password
Body: { 
  "email": "user@example.com", 
  "otp": "123456", 
  "newPassword": "newpassword123" 
}
Response: { "status": true, "message": "Password reset successfully" }
```

## Notes

- OTP is sent via **Brevo email** for email recovery
- OTP is sent via **SMS** for phone recovery
- OTP expires in **10 minutes**
- OTP is **6 digits**
- Password must be **minimum 8 characters**
- Backend uses `updateOrCreate` to avoid duplicate OTP records
