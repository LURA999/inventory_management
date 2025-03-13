class ImageData {
  late int? idMenu;
  late String name;
  late String imagePath;
  late double price;
  late String description;
  late int active;
  late int cveCategory;

  
  ImageData({
    this.idMenu,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.description,
    required this.active,
    required this.cveCategory
  });

// Método para convertir un JSON a un objeto ReportExcel
  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      idMenu: json['idMenu'],
      name: json['name'],
      imagePath: json['imagePath'],
      price: (json['price'] is int) ? json['price']+ 0.0 : json['price'],
      description: json['description'],
      active: json['active'],
      cveCategory : json['cveCategory']
    );
  }

  // Método para convertir un objeto ReportExcel a JSON
   Map<String, dynamic> toJson() {
    return {
      'idMenu': idMenu,
      'name': name,
      'imagePath': imagePath,
      'price': price,
      'description': description,
      'active': active,
      'cveCategory' :cveCategory
    };
  }

}