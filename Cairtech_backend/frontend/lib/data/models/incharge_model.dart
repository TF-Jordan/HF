class InchargeModel {
  final String? idUser;
  final String? function;
  final String? mandate;
  final String? nominationDate;
  final List<String>? competences;

  const InchargeModel({
    this.idUser,
    this.function,
    this.mandate,
    this.nominationDate,
    this.competences,
  });

  factory InchargeModel.fromJson(Map<String, dynamic> json) {
    return InchargeModel(
      idUser: json['idUser'] ?? json['id_user'],
      function: json['function'],
      mandate: json['mandate'],
      nominationDate: json['nominationDate'] ?? json['nomination_date'],
      competences: (json['competences'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'function': function,
      'mandate': mandate,
      'nominationDate': nominationDate,
      'competences': competences,
    };
  }
}
