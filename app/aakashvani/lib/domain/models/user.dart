import 'package:aakashvani/domain/role.dart';

class User {
  final String id;
  final String name;
  final Role role;
  final List<String> zoneScope;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.zoneScope,
    required this.token,
  });
}
