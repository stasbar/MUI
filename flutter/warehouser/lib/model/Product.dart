class Product{
  final String id;
  final String manufacturer;
  final String model;
  final int price;
  final int quantity;
  final int quantityLocal;
  final int quantityRem;
  final bool deleted;
  final int lastTimeModified;

  Product({this.id, this.manufacturer, this.model, this.price, this.quantity, this.lastTimeModified, this.deleted, this.quantityLocal, this.quantityRem});

  factory Product.fromJson(Map<String,dynamic> json) {
    return Product(
      id: json['id'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      price: json['price'],
      quantity: json['quantity'],
      lastTimeModified: json['lastTimeModified'],
      deleted: json['deleted'],
      quantityLocal: json['quantityLocal'],
      quantityRem: json['quantityRem'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'manufacturer': manufacturer,
        'model': model,
        'price': price,
        'quantity': quantity,
        'lastTimeModified': lastTimeModified,
        'deleted': deleted,
        'quantityLocal': quantityLocal,
        'quantityRem': quantityRem,
      };
}