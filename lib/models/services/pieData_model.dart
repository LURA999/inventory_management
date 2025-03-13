class PieDataModel {
  late int idMenu;
  late String name;
  late int amount;

  
  PieDataModel({
    required this.idMenu,
    required this.name,
    required this.amount,
  });

// Método para convertir un JSON a un objeto ReportExcel
  factory PieDataModel.fromJson(Map<String, dynamic> json) {
    return PieDataModel(
      idMenu: json['idMenu'],
      name: json['name'],
      amount: json['amount']
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      'idMenu': idMenu,
      'name': name,
      'amount': amount
    };
  }

}