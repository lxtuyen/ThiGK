import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  // Get all products from a collection
  final CollectionReference products = FirebaseFirestore.instance.collection('products');
  
  // create
  Future<void> add(String name, String category, String price, String imageURL) {
    return products.add({
      'name': name,
      'category': category,
      'price': price,
      'imageURL': imageURL,
      'timestamp': Timestamp.now(),
    });
  }

  // read
  Stream<QuerySnapshot> getProducts() {
    final productStream = products.orderBy('timestamp', descending: true).snapshots();

    return productStream;
  }

  // update
  Future<void> updateProduct(String id, String name, String category, String price,String imageURL) {
    return products.doc(id).update({
      'name': name,
      'category': category,
      'price': price,
      'imageURL': imageURL,
    });
  }

  // delete
  Future<void> removeProduct(String id) {
    return products.doc(id).delete();
  }
}
