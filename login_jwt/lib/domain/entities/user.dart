class User {
  final int userId;
  final String username;
  final String name;
  final String? token;

  const User({
    required this.userId,
    required this.username,
    required this.name,
    this.token,
  });
}
