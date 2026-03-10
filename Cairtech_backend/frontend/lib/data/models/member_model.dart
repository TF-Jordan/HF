class MemberModel {
  final String? idUser;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? quarter;
  final String? inscriptionDate;
  final String? status;
  final String? level;
  final String? sector;
  final String? idBbc;

  const MemberModel({
    this.idUser,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.quarter,
    this.inscriptionDate,
    this.status,
    this.level,
    this.sector,
    this.idBbc,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      idUser: json['idUser'] ?? json['id_user'],
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? json['date_of_birth'],
      gender: json['gender'],
      address: json['address'],
      quarter: json['quarter'],
      inscriptionDate: json['inscriptionDate'] ?? json['inscription_date'],
      status: json['status'],
      level: json['level'],
      sector: json['sector'],
      idBbc: json['idBbc'] ?? json['id_bbc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'quarter': quarter,
      'inscriptionDate': inscriptionDate,
      'status': status ?? 'ACTIVE',
      'level': level,
      'sector': sector,
      'idBBC': idBbc,
    };
  }

  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'ACTIVE';
}
