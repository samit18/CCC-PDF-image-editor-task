// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:new_app/pages/convert_image_format_page.dart'; 
import 'package:new_app/pages/convert_image_formate_page.dart';
import 'package:new_app/pages/Image%20Format%20Converter.dart'; 

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
      title: 'PDF & Image Editor',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/compressPdf': (context) => CompressedPdfPage(),
        '/imageToPdf': (context) => ImageToPdfPage(),
        '/compressImage': (context) => const CompressImagePage(),
        '/convertImageFormat': (context) => const FileConversionPage(),
        '/imageFormatConverter': (context) => ImageConverterPage(),
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
        title: const Text('PDF & Image Editor'),
        backgroundColor: Colors.deepPurple,  
      ),
      body: ListView(
        children: [
          _buildListTile(
            context,
            'Compress PDF',
            Colors.blue,
            '/compressPdf',
          ),
          _buildListTile(
            context,
            'Convert Images to PDF',
            Colors.green, 
            '/imageToPdf',
          ),
          _buildListTile(
            context,
            'Compress Images',
            Colors.orange, 
            '/compressImage',
          ),
          _buildListTile(
            context,
            'Convert Image Format',
            Colors.teal, 
            '/convertImageFormat',
          ),
          _buildListTile(
            context,
            'Image Format Converter',
            Colors.purple, 
            '/imageFormatConverter',
          
          ),
          _buildListTile(
            context,
            'Edit PDF',
            Colors.red,
            '/editPdf',
          ),
        ],
      ),
    );
  }

  
  Widget _buildListTile(BuildContext context, String title, Color backgroundColor, String route) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: MaterialButton(
        onPressed: () => Navigator.pushNamed(context, route),
        color: backgroundColor,
        height: 60,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ConvertPdfFormatPage extends StatelessWidget {
  const ConvertPdfFormatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convert PDF Format')),
      body: const Center(
        child: Text('This is the Convert PDF Format Page'),
      ),
    );
  }
}
