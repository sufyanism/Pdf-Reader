import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart' hide PdfController;

import '../controllers/pdf_controller.dart';
import '../core/responsive.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final controller = Get.find<PdfController>();

  PdfControllerPinch? pdfController;
  final isToolbarVisible = true.obs;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    createPdfController();

    ever(controller.resetViewerKey, (_) async {
      pdfController = null;
      if (mounted) setState(() {});
      await createPdfController();
    });

  }

  Future<void> createPdfController() async {
    final documentFuture =
    PdfDocument.openAsset(controller.assetPath);

    final document = await documentFuture;
    controller.setTotalPages(document.pagesCount);

    final newController = PdfControllerPinch(
      document: documentFuture,
      initialPage: controller.currentPage.value,
    );

    controller.attachViewer(newController);

    if (!mounted) return;

    setState(() {
      pdfController = newController;
    });
  }

  void toggleUI() {
    if (controller.isLocked.value) return;

    isToolbarVisible.value = !isToolbarVisible.value;

    if (isToolbarVisible.value) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        isToolbarVisible.value = false;
      });
    }
  }

  Widget glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentWidth = Responsive.contentWidth(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() => Scaffold(
      backgroundColor: controller.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [

            /// PDF VIEW
            GestureDetector(
              onTap: toggleUI,
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: pdfController == null
                      ? const Center(child: CircularProgressIndicator())
                      : Obx(() => Transform.scale(
                    scale: controller.zoomLevel.value,
                    child: PdfViewPinch(
                      key: ValueKey(
                          controller.resetViewerKey.value),
                      controller: pdfController!,
                      onPageChanged:
                      controller.updatePage,
                    ),
                  )),
                ),
              ),
            ),

            Obx(() => IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.black.withOpacity(
                  controller.brightnessOverlayOpacity,
                ),
              ),
            )),

            /// TOP BAR
            Obx(() => AnimatedPositioned(
              duration:
              const Duration(milliseconds: 300),
              top: isToolbarVisible.value
                  ? topPadding + 12
                  : -140,
              left: 16,
              right: 16,
              child: glassContainer(
                child: Column(
                  children: [

                    /// PAGE INFO
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Page ${controller.currentPage.value}/${controller.totalPages.value}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold),
                          ),
                        ),
                        Text(
                          controller.percentage,
                          style: const TextStyle(
                              color:
                              Colors.white70),
                        ),
                      ],
                    )),

                    const SizedBox(height: 10),

                    /// PROGRESS BAR
                    Obx(() => LinearProgressIndicator(
                      value:
                      controller.progress,
                      backgroundColor:
                      Colors.white24,
                      color:
                      Colors.lightBlueAccent,
                    )),
                  ],
                ),
              ),
            )),

            /// BOTTOM TOOLBAR
            Obx(() => AnimatedPositioned(
              duration:
              const Duration(milliseconds: 300),
              bottom: isToolbarVisible.value
                  ? 20
                  : -260,
              left: 16,
              right: 16,
              child: glassContainer(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [

                    /// NAVIGATION ROW
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.chevron_left,
                              color:
                              Colors.white),
                          onPressed:
                          controller.previousPage,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.chevron_right,
                              color:
                              Colors.white),
                          onPressed:
                          controller.nextPage,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.refresh,
                              color:
                              Colors.white),
                          onPressed:
                          controller.resetZoom,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// READING TOOLS
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.text_decrease,
                              color:
                              Colors.white),
                          onPressed:
                          controller.decreaseZoom,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.text_increase,
                              color:
                              Colors.white),
                          onPressed:
                          controller.increaseZoom,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: controller.showReaderSettings,
                        ),
                        IconButton(
                          icon: const Icon(Icons.brightness_6, color: Colors.white),
                          onPressed: () {
                            controller.themeIndex.value =
                                (controller.themeIndex.value + 1) % 5;
                          },
                        ),                        Obx(() => IconButton(
                          icon: Icon(
                            controller
                                .isLocked
                                .value
                                ? Icons.lock
                                : Icons
                                .lock_open,
                            color:
                            Colors.white,
                          ),
                          onPressed:
                          controller
                              .toggleLock,
                        )),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// EXTRA TOOLS
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.bookmark,
                              color:
                              Colors.white),
                          onPressed:
                          controller
                              .toggleBookmark,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.menu_book,
                              color:
                              Colors.white),
                          onPressed:
                          controller
                              .showTableOfContents,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.search,
                              color:
                              Colors.white),
                          onPressed:
                          controller
                              .showJumpDialog,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.notes,
                              color:
                              Colors.white),
                          onPressed:
                          controller
                              .showNotesDialog,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons
                                  .fullscreen_exit,
                              color:
                              Colors.white),
                          onPressed: () =>
                              Get.back(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// STATS
                    Obx(() => Text(
                      "🔥 ${controller.readingStreak.value} day streak • ⏱ ${controller.formattedTotalTime}",
                      style: const TextStyle(
                        color:
                        Colors.white70,
                        fontSize: 12,
                      ),
                    )),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    ),
    );
  }
}