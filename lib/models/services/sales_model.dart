class SalesModel {
  int? idSale;
  late String date;
  late int amount;
  late int cveMenu;
  late int id;

  SalesModel({
    this.idSale,
    required this.date,
    required this.amount,
    required this.cveMenu,
    required this.id
  });

  // Método para convertir un JSON a un objeto ReportExcel
  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      idSale: json['idSale'],
      date: json['date'],
      amount: json['amount'],
      cveMenu: json['cveMenu'],
      id: json['id']
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      'idSale': idSale,
      'date': date,
      'amount': amount,
      'cveMenu': cveMenu,
      'id': id
    };
  }

}