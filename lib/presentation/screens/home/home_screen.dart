import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giua_ky/presentation/screens/home/widgets/listview.dart';
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
  final TextEditingController searchController = TextEditingController();
  bool isPriceDescending = true;
  String searchQuery = '';

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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 7,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // ✅ Lưu lại giá trị tìm kiếm
                  });
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: IconButton(
                icon: Icon(Icons.filter_alt),
                onPressed: () {
                  setState(() {
                    isPriceDescending = !isPriceDescending;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: firestoreService.getProducts(
    name: searchController.text,
    isPriceDescending: isPriceDescending,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text("Không tìm thấy sản phẩm nào."));
    }

    List<DocumentSnapshot> productsList = snapshot.data!.docs;

    return ListView.builder(
      itemCount: productsList.length,
      itemBuilder: (context, index) {
        DocumentSnapshot doc = productsList[index];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return ListviewCustom(
          name: data['tensp'],
          category: data['loaisp'],
          price: data['gia'],
          imageURL: data['hinhanh'],
          id: doc.id,
          onDelete: () => _showDeleteConfirmationDialog(context, doc.id),
          onEdit: () => openDialog(
            context,
            doc.id,
            name: data['tensp'],
            category: data['loaisp'],
            price: data['gia'],
            imageURL: data['hinhanh'],
          ),
        );
      },
    );
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
