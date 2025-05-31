class Phone {
  final int id;
  final String name;
  final String brand;
  final int price;
  final String imgUrl;
  final String specification;
  final String createdAt;
  final String updatedAt;

  Phone({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imgUrl,
    required this.specification,
    required this.createdAt,
    required this.updatedAt,
  });


  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'],
      imgUrl: json['img_url'],
      specification: json['specification'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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