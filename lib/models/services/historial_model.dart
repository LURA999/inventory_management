class HistorialModel {
  late int id ;
  late DateTime date ;
  late String name ;
  late double total ;

  
  HistorialModel({
    required this.id,
    required this.date,
    required this.name,
    required this.total
  });

  // Método para convertir un JSON a un objeto ReportExcel
  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    return HistorialModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      total: json['total'] + 0.0
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'name': name,
      'total': total + 0.0
    };
  }

}