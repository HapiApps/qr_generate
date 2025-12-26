import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../view_models/qr_provider.dart';

enum DownloadType { png, pdf }

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QRProvider>(
      builder: (context, qrProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xFFE6E6FA),
            title: const Text(
              "QR Generator",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: Colors.black,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// PLAY STORE LINK
                  TextSelectionTheme(
                    data: TextSelectionThemeData(
                      selectionColor: Colors.green.shade100,
                      selectionHandleColor: Color(0xFF3DDC84),
                    ),
                    child: TextField(
                      cursorColor: Color(0xFF3DDC84),
                      controller: qrProvider.playStoreController,
                      onChanged: (_) {
                        setState(() {
                          qrProvider.clearQRIfInputsEmpty();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Play Store App Link",
                        // labelStyle: TextStyle(
                        //   color: Colors.grey.shade600,
                        // ),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        //hintText: "https://play.google.com/store/apps/details?id=...",
                        prefixIcon: const Icon(
                          Icons.android,
                          color: Color(0xFF3DDC84),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF3DDC84),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  /// APP STORE LINK
                  TextSelectionTheme(
                    data: TextSelectionThemeData(
                      selectionColor: Colors.black45,
                      selectionHandleColor: Colors.black,
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: qrProvider.appStoreController,
                      onChanged: (_) {
                        setState(() {
                          qrProvider.clearQRIfInputsEmpty();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "App Store App Link",
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        // hintText: "https://apps.apple.com/app/id...",
                        prefixIcon: const Icon(
                          Icons.apple,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  /// IMAGE PICK BUTTON
                  Consumer<QRProvider>(
                    builder: (context, qrProvider, _) {
                      final bool isLinkEntered =
                          qrProvider.playStoreController.text
                              .trim()
                              .isNotEmpty ||
                          qrProvider.appStoreController.text.trim().isNotEmpty;

                      return ElevatedButton.icon(
                        onPressed: isLinkEntered
                            ? () async {
                                await qrProvider.pickCenterImage();
                              }
                            : null,
                        icon: Icon(
                          Icons.image,
                          color: isLinkEntered ? Colors.white : Colors.grey,
                        ),
                        label: Text(
                          qrProvider.centerImage == null
                              ? "Pick Center Image"
                              : "Change Center Image",
                          style: TextStyle(
                            color: isLinkEntered
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLinkEntered
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300,
                          elevation: isLinkEntered ? 6 : 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  /// GENERATE QR BUTTON
                  ElevatedButton(
                    onPressed:
                        (qrProvider.playStoreController.text.trim().isEmpty &&
                            qrProvider.appStoreController.text.trim().isEmpty)
                        ? null
                        : () {
                            qrProvider.generateQRFromLinks();
                            _showDownloadDialog();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.qr_code_2_rounded, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Generate QR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ///  QR DISPLAY WITH CENTER IMAGE
                  Consumer<QRProvider>(
                    builder: (context, qrProvider, _) {
                      if (!qrProvider.isGenerated) return const SizedBox();

                      return Screenshot(
                        controller: qrProvider.screenshotController,
                        child: QrImageView(
                          data: qrProvider.qrData,
                          size: 220,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,

                          embeddedImage: qrProvider.centerImage != null
                              ? FileImage(qrProvider.centerImage!)
                              : null,

                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            size: Size(40, 40),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// DOWNLOAD POPUP
  void _showDownloadDialog() {
    DownloadType selected = DownloadType.png;
    final qrProvider = context.read<QRProvider>();
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xffE6E6FA),
              title: const Text("Download QR Code"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<DownloadType>(
                    title: const Text("Save as PNG"),
                    value: DownloadType.png,
                    groupValue: selected,
                    onChanged: (val) {
                      setState(() => selected = val!);
                    },
                  ),
                  RadioListTile<DownloadType>(
                    title: const Text("Save as PDF"),
                    value: DownloadType.pdf,
                    groupValue: selected,
                    onChanged: (val) {
                      setState(() => selected = val!);
                    },
                  ),
                ],
              ),
              actions: [
                /// CANCEL BUTTON
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                /// DOWNLOAD BUTTON
                ElevatedButton(
                  onPressed: () async {
                    if (selected == DownloadType.png) {
                      await qrProvider.savePNGAndOpen();
                    } else {
                      await qrProvider.savePDFAndOpen();
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text("QR Code downloaded successfully"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3D3FF),
                    // foregroundColor: Colors.white,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Download",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
