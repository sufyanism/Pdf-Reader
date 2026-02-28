import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pdf_controller.dart';

class BookmarksPage extends StatelessWidget {
  final controller = Get.find<PdfController>();
  BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarks"), centerTitle: true),
      body: Obx(() {
        if (controller.bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bookmark_border, size: 70, color: Colors.grey),
                SizedBox(height: 10),
                Text("No bookmarks added", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: controller.bookmarks.length,
          itemBuilder: (_, index) {
            final page = controller.bookmarks[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.bookmark, color: Colors.white),
                ),
                title: Text("Page $page", style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Tap to continue reading"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  controller.jumpToPage(page);
                  Get.back();
                },
              ),
            );
          },
        );
      }),
    );
  }
}