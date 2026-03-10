class BibleClubModel {
  final String? idBibleClub;
  final String name;
  final String code;
  final String? localisation;
  final String? ville;
  final String? schoolName;
  final String? schoolLevel;
  final String? dateCreation;
  final int? capacityMax;
  final String? status;

  const BibleClubModel({
    this.idBibleClub,
    required this.name,
    required this.code,
    this.localisation,
    this.ville,
    this.schoolName,
    this.schoolLevel,
    this.dateCreation,
    this.capacityMax,
    this.status,
  });

  factory BibleClubModel.fromJson(Map<String, dynamic> json) {
    return BibleClubModel(
      idBibleClub: json['idBibleClub'] ?? json['id_bible_club'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      localisation: json['localisation'],
      ville: json['ville'] ?? json['city'],
      schoolName: json['schoolName'] ?? json['school_name'],
      schoolLevel: json['schoolLevel'] ?? json['school_level'],
      dateCreation: json['dateCreation'] ?? json['date_creation'],
      capacityMax: json['capacityMax'] ?? json['capacity_max'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'localisation': localisation,
      'ville': ville,
      'schoolName': schoolName,
      'schoolLevel': schoolLevel,
      'dateCreation': dateCreation,
      'capacityMax': capacityMax,
      'status': status ?? 'ACTIVE',
    };
  }

  bool get isActive => status == 'ACTIVE';
}
