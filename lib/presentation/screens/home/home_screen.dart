import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giua_ky/services/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _image;
  String? _imageURL;

  // Hàm để chọn hình ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageURL = null;
      });
    }

    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/multi-library/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'multiLibrary'
          ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        final url = jsonMap['secure_url'];
        _imageURL = url;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                firestoreService.removeProduct(docId); // Xóa sản phẩm
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void openDialog(
    BuildContext context,
    String? id, {
    String? name,
    String? category,
    String? price,
    String? imageURL,
  }) {
    nameController.text = name ?? '';
    categoryController.text = category ?? '';
    priceController.text = price ?? '';
    _imageURL = imageURL;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                id != null ? 'Cập nhật sản phẩm mới' : 'Thêm sản phẩm',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tên sản phẩm
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Tên sản phẩm',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Loại sản phẩm
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        hintText: 'Loại sản phẩm',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Gía sản phẩm
                    TextField(
                      controller: priceController,
                      keyboardType:
                          TextInputType.number, // Chỉ hiển thị bàn phím số
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ], // Chỉ cho phép nhập số
                      decoration: const InputDecoration(
                        hintText: 'Giá sản phẩm',
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Nút để tải lên hình ảnh
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        await _pickImage();
                        setDialogState(() {}); // Cập nhật UI của hộp thoại
                      },
                      child: const Text(
                        'Tải lên hình ảnh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Hiển thị hình ảnh đã chọn (nếu có)
                    if (_image != null)
                      Image.file(
                        _image!,
                        height: 120,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    else if (_imageURL != null)
                      Image.network(
                        _imageURL!,
                        height: 120,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (id == null) {
                      firestoreService.add(
                        nameController.text,
                        categoryController.text,
                        priceController.text,
                        _imageURL!,
                      );
                    } else {
                      firestoreService.updateProduct(
                        id,
                        nameController.text,
                        categoryController.text,
                        priceController.text,
                        _imageURL!,
                      );
                    }

                    nameController.clear();
                    categoryController.clear();
                    priceController.clear();
                    _image = null;
                    _imageURL = null;
                    Navigator.of(context).pop();
                  },
                  child: Text(id != null ? 'Cập nhật' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sản phẩm')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List productsList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = productsList[index];
                String docId = doc.id;
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String name = data['name'];
                String category = data['category'];
                String price = data['price'];
                String imageURL = data['imageURL'];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: ListTile(
                    leading: Image.network(imageURL),
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loại: $category',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.apply(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Giá: $price Đồng',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.apply(color: Colors.red),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              () => openDialog(
                                context,
                                docId,
                                name: name,
                                category: category,
                                price: price,
                                imageURL: imageURL,
                              ),
                          icon: const Icon(Icons.settings),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, docId);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog(context, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
