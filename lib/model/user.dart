class UserModel {
  final String uid;
  final String name;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
  });

  // Chuyển đổi từ Map (Firestore) thành đối tượng UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // Chuyển đổi đối tượng UserModel thành Map (lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': DateTime.now(),
    };
  }
}