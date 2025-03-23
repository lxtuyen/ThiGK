import 'package:flutter/material.dart';

class ListviewCustom extends StatelessWidget {
  const ListviewCustom({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.imageURL,
    required this.onEdit,
    required this.onDelete, required this.id,
  });

  final String id, name, category, price,imageURL;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: ListTile(
        leading: Image.network(imageURL),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium!),
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
              onPressed: onEdit,
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                onDelete;
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
