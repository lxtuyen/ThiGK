import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  // Get collection
  final CollectionReference products = FirebaseFirestore.instance.collection('products');
  
  // create
  Future<void> add(String name, String category, String price, String imageURL) {
    return products.add({
      'tensp': name,
      'loaisp': category,
      'gia': price,
      'hinhanh': imageURL,
      'timestamp': Timestamp.now(),
    });
  }

  // update
  Future<void> updateProduct(String id, String name, String category, String price,String imageURL) {
    return products.doc(id).update({
      'tensp': name,
      'loaisp': category,
      'gia': price,
      'hinhanh': imageURL,
    });
  }

  // delete
  Future<void> removeProduct(String id) {
    return products.doc(id).delete();
  }
  Stream<QuerySnapshot> getProducts({String? name, bool? isPriceDescending}) {
  Query query = products;

  // Tìm kiếm theo tên nếu có nhập
  if (name != null && name.isNotEmpty) {
    query = query
        .where('tensp', isGreaterThanOrEqualTo: name)
        .where('tensp', isLessThan: name + 'z');
    return query.snapshots();
  }

  // Sắp xếp theo giá nếu có yêu cầu
  if (isPriceDescending != null) {
    query = query.orderBy('gia', descending: isPriceDescending);
  } else {
    // Mặc định sắp xếp theo thời gian thêm mới nhất
    query = query.orderBy('timestamp', descending: true);
  }

  return query.snapshots();
}

}
