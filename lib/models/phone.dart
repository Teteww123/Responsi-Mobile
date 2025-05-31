class Phone {
  final int id;
  final String name;
  final String brand;
  final int price;
  final String specification;

  Phone({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.specification,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'],
      specification: json['specification'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "brand": brand,
      "price": price,
      "specification": specification,
    };
  }
}