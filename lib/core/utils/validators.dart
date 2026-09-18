class PasswordStrength {
  final int score; // 0 to 4
  final String label;

  const PasswordStrength({required this.score, required this.label});
}

class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email atau No. WhatsApp tidak boleh kosong';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^[0-9+]{8,15}$');

    if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
      return 'Format email atau no. WhatsApp tidak valid';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat email tidak boleh kosong';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final trimmed = value.trim();
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Nomor telepon minimal 8-15 digit angka';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }

  static PasswordStrength calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(score: 0, label: 'Lemah');
    }

    int score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }

    // Ensure at least 1 bar if not empty
    if (score == 0 && password.isNotEmpty) score = 1;

    String label;
    if (score <= 1) {
      label = 'Lemah';
    } else if (score <= 2) {
      label = 'Sedang';
    } else if (score <= 3) {
      label = 'Kuat';
    } else {
      label = 'Sangat Kuat';
    }

    return PasswordStrength(score: score, label: label);
  }
}
