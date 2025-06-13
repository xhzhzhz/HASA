import 'dart:convert';

class Patient {
  int? id;
  String nama;
  int nik;
  int umur;
  String alamat;
  int kontak;
  DateTime tanggal;
  Map<String, bool> gejala;
  Map<String, bool> risiko;
  bool isPemeriksaanSelesai;
  DateTime? createdAt;
  DateTime? updatedAt;

  Patient({
    this.id,
    required this.nama,
    required this.nik,
    required this.umur,
    required this.alamat,
    required this.kontak,
    required this.tanggal,
    required this.gejala,
    required this.risiko,
    this.isPemeriksaanSelesai = false,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Patient object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'umur': umur,
      'alamat': alamat,
      'kontak': kontak,
      'tanggal': tanggal.toIso8601String(),
      'gejala': jsonEncode(gejala),
      'risiko': jsonEncode(risiko),
      'isPemeriksaanSelesai': isPemeriksaanSelesai ? 1 : 0,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Create Patient object from Map (database result)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      nama: map['nama'] ?? '',
      nik: map['nik'] ?? '',
      umur: map['umur'] ?? '',
      alamat: map['alamat'] ?? '',
      kontak: map['kontak'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      gejala: _parseJsonMap(map['gejala']),
      risiko: _parseJsonMap(map['risiko']),
      isPemeriksaanSelesai: (map['isPemeriksaanSelesai'] ?? 0) == 1,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Helper method to parse JSON string to Map<String, bool>
  static Map<String, bool> _parseJsonMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return <String, bool>{};
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value as bool));
      }
      return <String, bool>{};
    } catch (e) {
      print('Error parsing JSON: $e');
      return <String, bool>{};
    }
  }

  // Convert to JSON string
  String toJson() => jsonEncode(toMap());

  // Create Patient from JSON string
  factory Patient.fromJson(String source) =>
      Patient.fromMap(jsonDecode(source));

  // Copy with method for updating specific fields
  Patient copyWith({
    int? id,
    String? nama,
    int? nik,
    int? umur,
    String? alamat,
    int? kontak,
    DateTime? tanggal,
    Map<String, bool>? gejala,
    Map<String, bool>? risiko,
    bool? isPemeriksaanSelesai,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      umur: umur ?? this.umur,
      alamat: alamat ?? this.alamat,
      kontak: kontak ?? this.kontak,
      tanggal: tanggal ?? this.tanggal,
      gejala: gejala ?? this.gejala,
      risiko: risiko ?? this.risiko,
      isPemeriksaanSelesai: isPemeriksaanSelesai ?? this.isPemeriksaanSelesai,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, nama: $nama, nik: $nik, umur: $umur, alamat: $alamat, kontak: $kontak, tanggal: $tanggal, isPemeriksaanSelesai: $isPemeriksaanSelesai)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id && other.nik == nik;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nik.hashCode;
  }
}
