class User {
  final String id;
  final String nom;
  final String prenom;
  final String password;
  final String adresse;
  final String email;
  final String telephone;
  final String cni;
  final DateTime dateNaissance;
  final String etatCompte;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.password,
    required this.adresse,
    required this.email,
    required this.telephone,
    required this.cni,
    required this.dateNaissance,
    required this.etatCompte,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? password,
    String? adresse,
    String? email,
    String? telephone,
    String? cni,
    DateTime? dateNaissance,
    String? etatCompte,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      password: password ?? this.password,
      adresse: adresse ?? this.adresse,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      cni: cni ?? this.cni,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      etatCompte: etatCompte ?? this.etatCompte,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      password: json['password'],
      adresse: json['adresse'],
      email: json['email'],
      telephone: json['telephone'],
      cni: json['cni'],
      dateNaissance: DateTime.parse(json['date_naissance']),
      etatCompte: json['etat_compte'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'password': password,
      'adresse': adresse,
      'email': email,
      'telephone': telephone,
      'cni': cni,
      'date_naissance': dateNaissance.toIso8601String(),
      'etat_compte': etatCompte,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}