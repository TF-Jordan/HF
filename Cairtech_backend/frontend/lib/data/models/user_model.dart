class UserModel {
  final String? idUser;
  final String email;
  final String? phoneNumber;
  final String? status;
  final bool? active;
  final String? lastConnectionDate;
  final List<String> roles;

  const UserModel({
    this.idUser,
    required this.email,
    this.phoneNumber,
    this.status,
    this.active,
    this.lastConnectionDate,
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id']?.toString() ?? json['idUser']?.toString() ?? json['id_user']?.toString(),
      email: json['email']?.toString() ?? json['sub']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
      status: json['status']?.toString(),
      active: json['active'] is bool ? json['active'] : null,
      lastConnectionDate: json['lastConnectionDate']?.toString(),
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'status': status,
    };
  }

  bool get isSuperAdmin => roles.contains('SUPER_ADMIN');
  bool get isAdmin => roles.contains('ADMIN') || isSuperAdmin;
  bool get isPresident => roles.contains('PRESIDENT');
  bool get isLeader => roles.contains('LEADER');
  bool get isUser => roles.contains('USER');

  /// Returns the highest role for display purposes
  String get highestRole {
    if (isSuperAdmin) return 'SUPER_ADMIN';
    if (isAdmin) return 'ADMIN';
    if (isPresident) return 'PRESIDENT';
    if (isLeader) return 'LEADER';
    return 'USER';
  }
}
