class AppUser {
  const AppUser({required this.name, required this.email, required this.role, this.photoUrl});

  final String name;
  final String email;
  final String role;

  /// Profile photo: an `http(s)` URL from the backend, or a bundled asset path.
  final String? photoUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    photoUrl: json['photoUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'role': role, 'photoUrl': photoUrl};
}
