class UserModel {
  final int userId;
  final String username;
  final String name;
  final String? token;

  UserModel({
    required this.userId,
    required this.username,
    required this.name,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.parse(json['userId'].toString()),
      username: json['username'] as String,
      name: json['name'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'name': name,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? userId,
    String? username,
    String? name,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      name: name ?? this.name,
      token: token ?? this.token,
    );
  }
}
