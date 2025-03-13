class ReportsExcel {
  final int idSale;
  final DateTime date;
  final int idMenu;
  final String name;
  final int cantidad;
  final double price;

   // Constructor
  ReportsExcel({
    required this.idSale,
    required this.date,
    required this.idMenu,
    required this.name,
    required this.cantidad,
    required this.price,
  });

   int get propertyCount => 6;

  // Método para convertir un JSON a un objeto ReportExcel
  factory ReportsExcel.fromJson(Map<String, dynamic> json) {
    return ReportsExcel(
      idSale: json['idSale'],
      date: DateTime.parse(json['date']),
      idMenu: json['idMenu'],
      name: json['name'],
      cantidad: json['cantidad'],
      price: json['price'],
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
  Map<String, dynamic> toJson() {
    return {
      'idSale': idSale,
      'date': date.toIso8601String(),
      'idMenu': idMenu,
      'name': name,
      'cantidad': cantidad,
      'price': price,
    };
  }
}