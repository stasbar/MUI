class Product{
  final String id;
  final String manufacturer;
  final String model;
  final double price;
  final int quantity;

  Product({this.id, this.manufacturer, this.model, this.price, this.quantity});

  factory Product.fromJson(Map<String,dynamic> json) {

    return Product(
      id: json['id'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}