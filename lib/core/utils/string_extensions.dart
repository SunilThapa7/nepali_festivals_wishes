extension StringExtensions on String {
  /// Capitalize first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word in the string
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Truncate string to a specific length with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Check if string is a valid email address
  bool get isValidEmail {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
    );
    return urlRegExp.hasMatch(this);
  }

  /// Check if string is a valid phone number (simple validation)
  bool get isValidPhone {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,14}$');
    return phoneRegExp.hasMatch(this);
  }

  /// Remove all HTML tags from string
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Get a color hash from a string (consistent for same string)
  int get colorHash {
    int hash = 0;
    for (var i = 0; i < length; i++) {
      hash = codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs() % 0xFFFFFF;
  }
}
