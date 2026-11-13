bool isValidGmail(String email) {
  return RegExp(
    r'^[A-Z0-9._%+-]+@gmail\.com$',
    caseSensitive: false,
  ).hasMatch(email.trim());
}
