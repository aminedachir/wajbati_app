class AppUser {
  final String uid;
  final String email;
  final String name;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
