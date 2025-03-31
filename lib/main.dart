import 'package:flutter/material.dart';
import 'package:new_app/pages/convert_image_format_page.dart';
import 'package:new_app/pages/convert_image_formate_page.dart';
import 'package:new_app/pages/image_to_pdf.dart';
import 'package:new_app/pages/compress_pdf_page.dart';
import 'package:new_app/pages/compress_image_page.dart';
import 'package:new_app/pages/edit_pdf_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF & Image Editor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/compressPdf': (context) => CompressedPdfPage(),
        '/imageToPdf': (context) => ImageToPdfPage(),
        '/compressImage': (context) =>const  CompressImagePage(),
        '/convertImageFormat': (context) => const FileConversionPage(),
        '/editPdf': (context) => const EditPdfPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF & Image Editor',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildGridTile(context, 'Compress PDF', Icons.picture_as_pdf, Colors.blue, '/compressPdf'),
            _buildGridTile(context, 'Convert to PDF', Icons.picture_in_picture_alt, Colors.green, '/imageToPdf'),
            _buildGridTile(context, 'Compress Images', Icons.image, Colors.orange, '/compressImage'),
            _buildGridTile(context, 'Convert Image Format', Icons.transform, Colors.teal, '/convertImageFormat'),
            _buildGridTile(context, 'Edit PDF', Icons.edit, Colors.red, '/editPdf'),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
