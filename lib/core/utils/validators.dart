class AppValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }
}
