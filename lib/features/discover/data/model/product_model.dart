// import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  // final String? id;
  final String productName;
  final String productImage;
  final String company;
  final String date;
  final String quantity;
  final String netCP;
  final String saleCP;
  final String productType;
  final String sellerContact;
  final String totalCP;
  final String room;

  const ProductModel({
    // this.id,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.netCP,
    required this.saleCP,
    required this.company,
    required this.sellerContact,
    required this.date,
    required this.totalCP,
    required this.room,
    required this.productType,
  });
  toJson() {
    return {
      "Name": productName,
      "Image": productImage,
      "Quantity": quantity,
      "NetCP": netCP,
      "SaleCP": saleCP,
      "Date": date,
      "SellerContact": sellerContact,
      "TotalCP": totalCP,
      "Company": company,
      "room": room,
      "ProductType": productType,
    };
  }

//   factory ProductModel.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return ProductModel(
//       // id: document.id,
//       productName: data["Name"],
//       productImage: data["Image"],
//       quantity: data["Quantity"],
//       room: data["room"],
//       netCP: data["NetCP"],
//       saleCP: data["SaleCP"],
//       company: data["Company"],
//       date: data["Date"],
//       sellerContact: data["SellerContact"],
//       totalCP: data["TotalCP"],
//       productType: data["ProductType"],
//     );
//   }
}
