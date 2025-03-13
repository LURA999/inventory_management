class ReportsModel {
  late int idMenu;
  late String date;
  late int idSale;
  late String name;
  late double price;
  late int amount;

  
  ReportsModel({
    required this.idMenu,
    required this.date,
    required this.idSale,
    required this.name,
    required this.price,
    required this.amount,
  });

// Método para convertir un JSON a un objeto ReportExcel
  factory ReportsModel.fromJson(Map<String, dynamic> json) {
    return ReportsModel(
      idMenu: json['idMenu'],
      date: json['date'],
      idSale: json['idSale'],
      name: json['name'],
      price: json['price'],
      amount: json['amount']
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      'idMenu': idMenu,
      'date': date,
      'idSale': idSale,
      'name': name,
      'price': price,
      'amount': amount
    };
  }

}