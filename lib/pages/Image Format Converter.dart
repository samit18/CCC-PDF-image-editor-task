import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:archive/archive.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Conversion',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FileConversionPage(),
    );
  }
}

class FileConversionPage extends StatefulWidget {
  const FileConversionPage({Key? key}) : super(key: key);

  @override
  _FileConversionPageState createState() => _FileConversionPageState();
}

class _FileConversionPageState extends State<FileConversionPage> {
  File? _pickedFile;
  String? _filePreview;
  String _statusMessage = "No file selected.";
  String _convertedDocxFilePath = "";
  String _docxContent = "";

  PDFViewController? _pdfViewController;

  Future<void> _pickPDFFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      
      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);

        setState(() {
          _pickedFile = pickedFile;
          _filePreview = pickedFile.path;
          _statusMessage = "PDF file selected successfully.";
          _convertedDocxFilePath = "";
        });
      } else {
        setState(() {
          _statusMessage = "No PDF file selected.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error picking file: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('File Conversion')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickPDFFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: const Text('Pick a PDF File'),
                ),
                const SizedBox(height: 20),
                if (_pickedFile != null)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Convert to DOCX'),
                  ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
