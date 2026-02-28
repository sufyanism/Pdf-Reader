import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../models/toc_item.dart';
import '../services/storage_service.dart';
import '../services/toc_service.dart';

class PdfController extends GetxController {

  /// ================= STATE =================
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var bookmarks = <int>[].obs;
  var toc = <TocItem>[].obs;
  var isTocLoading = false.obs;


  /// ================= NEW READER CUSTOMIZATION =================

  /// Brightness (0 = dark overlay, 1 = full bright)
  var brightnessLevel = 1.0.obs;

  /// Theme index (0=dark,1=light,2=sepia,3=gray,4=night blue)
  var themeIndex = 0.obs;

  /// Font family (for UI elements & notes)
  var fontFamily = "Default".obs;

  /// Font weight
  var fontWeightIndex = 0.obs; // 0=normal,1=medium,2=bold

  /// NEW FEATURES (Existing from you)
  var searchQuery = "".obs;
  var readingMode = 0.obs; // 0 = dark, 1 = light, 2 = sepia
  var favoriteChapters = <int>[].obs;
  var readingSeconds = 0.obs;
  Timer? _readingTimer;

  /// ================= NEW KINDLE FEATURES =================

  /// Persistent total reading time
  var totalReadingSeconds = 0.obs;

  /// Reading streak
  var readingStreak = 0.obs;

  /// Lock mode
  var isLocked = false.obs;

  /// Font zoom presets (simulate Kindle font size)
  var zoomLevel = 1.0.obs;

  /// rebuild viewer trigger
  var resetViewerKey = 0.obs;

  PdfControllerPinch? pdfViewerController;

  final String assetPath = 'assets/pdf/book.pdf';

  /// ================= INIT =================
  @override
  void onInit() {
    bookmarks.value = StorageService.getBookmarks();
    currentPage.value = StorageService.getLastPage();
    readingMode.value = StorageService.getReadingMode();
    favoriteChapters.value = StorageService.getFavoriteChapters();
    themeIndex.value = StorageService.getTheme();
    brightnessLevel.value = StorageService.getBrightness();
    fontFamily.value = StorageService.getFontFamily();
    fontWeightIndex.value = StorageService.getFontWeight();

    /// NEW LOAD
    totalReadingSeconds.value =
        StorageService.getTotalReadingSeconds();
    readingStreak.value =
        StorageService.getReadingStreak();

    _updateReadingStreak();
    startReadingTimer();

    super.onInit();
  }

  Color get backgroundColor {
    switch (themeIndex.value) {
      case 1:
        return Colors.white;
      case 2:
        return const Color(0xffF5ECD9); // Sepia
      case 3:
        return Colors.grey.shade300;
      case 4:
        return const Color(0xff0D1B2A); // Night blue
      default:
        return Colors.black;
    }
  }

  double get brightnessOverlayOpacity {
    return 1 - brightnessLevel.value;
  }



  /// ================= READING TIMER =================
  void startReadingTimer() {
    _readingTimer?.cancel();
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      readingSeconds.value++;
      totalReadingSeconds.value++;

      StorageService.saveTotalReadingSeconds(
          totalReadingSeconds.value);
    });
  }

  @override
  void onClose() {
    _readingTimer?.cancel();
    super.onClose();
  }

  /// ================= STREAK LOGIC =================
  void _updateReadingStreak() {
    final today = DateTime.now().toString().split(" ")[0];
    final lastDate = StorageService.getLastReadDate();

    if (lastDate == null) {
      readingStreak.value = 1;
    } else {
      final yesterday =
      DateTime.now().subtract(const Duration(days: 1));
      final yDate = yesterday.toString().split(" ")[0];

      if (lastDate == today) return;

      if (lastDate == yDate) {
        readingStreak.value++;
      } else {
        readingStreak.value = 1;
      }
    }

    StorageService.saveLastReadDate(today);
    StorageService.saveReadingStreak(readingStreak.value);
  }

  /// ================= VIEWER =================
  void attachViewer(PdfControllerPinch controller) {
    pdfViewerController = controller;
    Future.delayed(const Duration(milliseconds: 50), () {
      pdfViewerController?.jumpToPage(currentPage.value);
    });
  }

  void setTotalPages(int pages) {
    totalPages.value = pages;
  }

  /// ================= PAGE =================
  void updatePage(int page) {
    currentPage.value = page;
    StorageService.saveLastPage(page);
  }

  Future<void> jumpToPage(int page) async {
    if (page < 1 || page > totalPages.value) return;

    if (pdfViewerController == null) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    pdfViewerController?.jumpToPage(page);
    currentPage.value = page;
    StorageService.saveLastPage(page);
  }


  void nextPage() {
    if (currentPage.value < totalPages.value) {
      jumpToPage(currentPage.value + 1);
    }
  }


  void previousPage() {
    if (currentPage.value > 1) {
      jumpToPage(currentPage.value - 1);
    }
  }

  /// ================= PROGRESS =================
  double get progress =>
      totalPages.value == 0
          ? 0
          : currentPage.value / totalPages.value;

  /// Percentage text
  String get percentage =>
      "${(progress * 100).toStringAsFixed(1)}%";

  /// ================= ZOOM =================
  void resetZoom() {
    resetViewerKey.value++;
  }

  /// Kindle zoom preset
  void increaseZoom() {
    zoomLevel.value += 0.2;
  }

  void decreaseZoom() {
    if (zoomLevel.value > 0.6) {
      zoomLevel.value -= 0.2;
    }
  }

  /// ================= LOCK MODE =================
  void toggleLock() {
    isLocked.value = !isLocked.value;
  }

  /// ================= READING MODE =================
  void changeReadingMode(int mode) {
    readingMode.value = mode;
    StorageService.saveReadingMode(mode);
  }

  /// ================= SEARCH =================
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// ================= BOOKMARK =================
  void toggleBookmark() {
    final page = currentPage.value;

    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
    }

    bookmarks.sort();
    StorageService.saveBookmarks(bookmarks);
  }

  bool isBookmarked(int page) {
    return bookmarks.contains(page);
  }

  /// ================= FAVORITE CHAPTER =================
  void toggleFavoriteChapter(int page) {
    if (favoriteChapters.contains(page)) {
      favoriteChapters.remove(page);
    } else {
      favoriteChapters.add(page);
    }
    StorageService.saveFavoriteChapters(favoriteChapters);
  }

  bool isFavoriteChapter(int page) {
    return favoriteChapters.contains(page);
  }

  /// ================= TABLE OF CONTENTS =================
  Future<void> loadTableOfContents() async {
    if (toc.isNotEmpty) return;

    isTocLoading.value = true;
    toc.value = await TocService.generateTOC(assetPath);
    isTocLoading.value = false;
  }

  void showTableOfContents() async {
    await loadTableOfContents();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() {
          if (isTocLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: toc.length,
            itemBuilder: (_, index) {
              final item = toc[index];

              return ListTile(
                title: Text(item.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text("Page ${item.page}",
                    style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: Icon(
                    isFavoriteChapter(item.page)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () =>
                      toggleFavoriteChapter(item.page),
                ),
                onTap: () {
                  Get.back();
                  jumpToPage(item.page);
                },
              );
            },
          );
        }),
      ),
    );
  }

  /// ================= JUMP PAGE =================
  void showJumpDialog() {
    final text = TextEditingController();

    Get.defaultDialog(
      title: "Go to Page",
      content: TextField(
        controller: text,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Enter page number",
        ),
      ),
      textConfirm: "Go",
      onConfirm: () {
        final page = int.tryParse(text.text);
        if (page != null) jumpToPage(page);
        Get.back();
      },
    );
  }

  var pageNotes = <int, String>{}.obs;

  void showNotesDialog() {
    final page = currentPage.value;
    final textController = TextEditingController(
      text: pageNotes[page] ?? "",
    );

    Get.defaultDialog(
      title: "Notes - Page $page",
      content: TextField(
        controller: textController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "Write your note...",
        ),
      ),
      textConfirm: "Save",
      onConfirm: () {
        pageNotes[page] = textController.text;
        Get.back();
      },
    );
  }

  /// ================= READING STATS =================
  String get formattedTotalTime {
    final minutes = totalReadingSeconds.value ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return "$hours h $remainingMinutes m";
  }

  /// ================= BOOKMARK LIST DIALOG =================
  void showBookmarksDialog() {
    if (bookmarks.isEmpty) {
      Get.snackbar(
        "Bookmarks",
        "No bookmarks added",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Obx(
              () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bookmarks",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (_, index) {
                    final page = bookmarks[index];

                    return ListTile(
                      title: Text(
                        "Page $page",
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        jumpToPage(page);
                        Get.back();
                      },
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          bookmarks.remove(page);
                          StorageService.saveBookmarks(bookmarks);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showReaderSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Brightness",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Obx(() => Slider(
                value: brightnessLevel.value,
                min: 0.3,
                max: 1.0,
                onChanged: (v) {
                  brightnessLevel.value = v;
                  StorageService.saveBrightness(v);
                },
              )),

              const SizedBox(height: 20),

              const Text("Theme",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Obx(() => Wrap(
                spacing: 10,
                children: List.generate(5, (index) {
                  return ChoiceChip(
                    label: Text("T$index"),
                    selected: themeIndex.value == index,
                    onSelected: (_) {
                      themeIndex.value = index;
                      StorageService.saveTheme(index);
                    },
                  );
                }),
              )),

              const SizedBox(height: 20),

              const Text("Font Style",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Obx(() => DropdownButton<String>(
                value: fontFamily.value,
                items: const [
                  DropdownMenuItem(
                      value: "Default", child: Text("Default")),
                  DropdownMenuItem(
                      value: "Serif", child: Text("Serif")),
                  DropdownMenuItem(
                      value: "Monospace",
                      child: Text("Monospace")),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  fontFamily.value = v;
                  StorageService.saveFontFamily(v);
                },
              )),

              const SizedBox(height: 20),

              const Text("Font Weight",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Obx(() => Wrap(
                spacing: 10,
                children: List.generate(3, (index) {
                  return ChoiceChip(
                    label: Text(
                        index == 0
                            ? "Normal"
                            : index == 1
                            ? "Medium"
                            : "Bold"),
                    selected: fontWeightIndex.value == index,
                    onSelected: (_) {
                      fontWeightIndex.value = index;
                      StorageService.saveFontWeight(index);
                    },
                  );
                }),
              )),
            ],
          ),
        ),
      ),
    );
  }
}