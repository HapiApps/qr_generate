import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scan/view_models/qr_provider.dart';
import 'package:qr_scan/views/qr_generate_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QRProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRScreen(),
    );
  }
}

