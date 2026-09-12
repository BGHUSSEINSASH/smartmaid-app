/// تقييم قوة كلمة المرور — يُستخدم في مؤشر بصري في شاشة التسجيل.
class PasswordStrength {
  final int score; // 0..4
  final String label;

  const PasswordStrength(this.score, this.label);

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return const PasswordStrength(0, '');
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) score++;
    score = score.clamp(0, 4);
    const labels = ['ضعيفة جداً', 'ضعيفة', 'متوسطة', 'جيدة', 'قوية'];
    return PasswordStrength(score, labels[score]);
  }
}
