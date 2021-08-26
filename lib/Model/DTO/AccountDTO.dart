class AccountDTO {
  final String name;
  final String phone;
  final DateTime birthdate;
  final int role;
  ReportDTO report;
  AccountDTO({
    this.name,
    this.phone,
    this.birthdate,
    this.role,
    this.report
  });

  factory AccountDTO.fromJson(dynamic json) => AccountDTO(
        name: json['name'] as String ?? "Bean",
        phone: json['phone'] as String,
        birthdate: json['birth_day'] as String != null
            ? DateTime.parse(json['birth_day'] as String)
            : null,
    role: (json['roles'] as List).first
      );



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "birth_day": birthdate.toString(),
    };
  }
}

class ReportDTO{
  int package;
  int distance;

  ReportDTO({this.package, this.distance});

  factory ReportDTO.fromJson(dynamic json) => ReportDTO(
    package: json['total_package'],
    distance: json['total_distance_travel']
  );

  Map<String, dynamic> toJson(){
    return {
      'total_package' : package,
      'total_distance_travel' : distance,
    };
  }
}
