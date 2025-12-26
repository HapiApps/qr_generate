import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
class QRProvider extends ChangeNotifier {
  String qrData = "";
  bool isGenerated = false;
  void clearQRIfInputsEmpty() {
    if (playStoreController.text.trim().isEmpty &&
        appStoreController.text.trim().isEmpty) {
      qrData = "";
      isGenerated = false;
      centerImage = null;
      notifyListeners();
    }
  }
  /// CONTROLLERS
  final TextEditingController playStoreController = TextEditingController();
  final TextEditingController appStoreController = TextEditingController();
  final ScreenshotController screenshotController = ScreenshotController();
  /// GENERATE QR FROM CONTROLLERS
  void generateQRFromLinks() {
    final playLink = playStoreController.text.trim();
    final appLink = appStoreController.text.trim();

    if (playLink.isEmpty && appLink.isEmpty) return;
    qrData = [
      if (playLink.isNotEmpty) playLink,
      if (appLink.isNotEmpty) appLink,
    ].join('\n');

    isGenerated = true;
    notifyListeners();
  }
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) return true;
      if (await Permission.photos.request().isGranted) return true;
      return false;
    }
    return true;
  }
  /// PNG → Save → OPEN GALLERY IMAGE
  Future<void> _scanFile(String path) async {
    const platform = MethodChannel('media_scanner');
    try {
      await platform.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      debugPrint("Media scan failed: $e");
    }
  }
  Future<void> savePNGAndOpen() async {
    final granted = await _requestPermission();
    if (!granted) return;
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;
    final directory = Directory("/storage/emulated/0/Pictures/QR");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File(
      "${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png",
    );
    await file.writeAsBytes(image);
    /// notify Gallery
    await _scanFile(file.path);
    /// (viewer open)
    await OpenFilex.open(file.path);
  }
  /// PDF → Save → OPEN PDF VIEWER
  Future<void> savePDFAndOpen() async {
    final granted = await _requestPermission();
    if (!granted) return;
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(
          child: pw.Image(pw.MemoryImage(image)),
        ),
      ),
    );

    final directory = Directory("/storage/emulated/0/Download");
    final file = File(
      "${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    /// OPEN PDF VIEWER
    await OpenFilex.open(file.path);
  }
  /// Center IMAGE
  File? centerImage;
  Future<void> pickCenterImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      centerImage = File(picked.path);
      notifyListeners();
    }
  }
}

