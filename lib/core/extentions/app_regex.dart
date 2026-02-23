class AppRegex {
  static bool isEmailValid(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    String passwordPattern =
        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$'; // Minimum 8 characters, at least one letter and one number
    RegExp regex = RegExp(passwordPattern);
    return regex.hasMatch(password);
  }

  static bool isEgyptianPhoneValid(String phone) {
    String pattern = r'^01[0125][0-9]{8}$';
    return RegExp(pattern).hasMatch(phone);
  }

  static bool isEgyptianLandlineValid(String phone) {
    String pattern = r'^0[23][0-9]{7,8}$';
    return RegExp(pattern).hasMatch(phone);
  }
}
