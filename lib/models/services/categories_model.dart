class Categories {
  late int? idCategory;
  late String name;
  late int active;

  
  Categories({
    this.idCategory,
    required this.name,
    required this.active
  });

  // Método para convertir un JSON a un objeto ReportExcel
  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      idCategory: json['idCategory'],
      name: json['name'],
      active: json['active']
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      "idCategory": idCategory.toString(),
      "name": name,
      "active": active.toString()
    };
  }

}