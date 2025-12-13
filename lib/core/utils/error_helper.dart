import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Error Helper Utility
/// 
/// Converts technical errors into user-friendly localized messages.
/// Handles connection errors, socket exceptions, and other common issues.
class ErrorHelper {
  /// Format error message to be user-friendly and localized
  /// 
  /// Converts technical errors like "SocketException: Connection refused"
  /// into user-friendly localized messages
  static String formatErrorMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    
    // Handle validation failed errors - check for specific validation messages
    // Check for both email and username first (most specific case)
    final hasEmailError = lowerError.contains('email') && 
        (lowerError.contains('already') || lowerError.contains('taken') || lowerError.contains('already been taken'));
    final hasUsernameError = lowerError.contains('username') && 
        (lowerError.contains('already') || lowerError.contains('taken') || lowerError.contains('already been taken'));
    
    if (hasEmailError && hasUsernameError) {
      return l10n.emailAndUsernameAlreadyTaken;
    }
    
    // Check for email already taken
    if (hasEmailError) {
      return l10n.emailAlreadyTaken;
    }
    
    // Check for username already taken
    if (hasUsernameError) {
      return l10n.usernameAlreadyTaken;
    }
    
    // Handle socket/connection errors
    if (lowerError.contains('socket') || 
        lowerError.contains('connection refused') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network is unreachable')) {
      return l10n.connectionErrorMessage;
    }
    
    // Handle timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return l10n.timeoutErrorMessage;
    }
    
    // Handle server errors
    if (lowerError.contains('500') || lowerError.contains('internal server error')) {
      return l10n.serverErrorMessage;
    }
    
    // Handle unauthorized errors
    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return l10n.authenticationFailedMessage;
    }
    
    // Handle bad request errors
    if (lowerError.contains('bad request') || lowerError.contains('400')) {
      return l10n.invalidRequestMessage;
    }
    
    // Handle not found errors
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return l10n.serviceNotFoundMessage;
    }
    
    // Handle server unavailable
    if (lowerError.contains('service unavailable') || lowerError.contains('503')) {
      return l10n.serviceUnavailableMessage;
    }
    
    // Handle generic network errors
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return l10n.networkErrorMessage;
    }
    
    // Truncate very long error messages
    if (error.length > 150) {
      return l10n.genericError;
    }
    
    // Return original error for short, readable messages
    return error;
  }
  
  /// Get user-friendly error title based on error type (localized)
  static String getErrorTitle(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('socket') || 
        lowerError.contains('connection refused') ||
        lowerError.contains('network')) {
      return l10n.connectionError;
    }
    
    if (lowerError.contains('timeout')) {
      return l10n.timeoutError;
    }
    
    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return l10n.authenticationFailed;
    }
    
    if (lowerError.contains('500') || lowerError.contains('server error')) {
      return l10n.serverError;
    }
    
    if (lowerError.contains('bad request') || lowerError.contains('400')) {
      return l10n.invalidRequest;
    }
    
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return l10n.serviceNotFound;
    }
    
    if (lowerError.contains('service unavailable') || lowerError.contains('503')) {
      return l10n.serviceUnavailable;
    }
    
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return l10n.networkError;
    }
    
    return l10n.error;
  }
}

