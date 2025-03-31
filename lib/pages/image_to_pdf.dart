import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() {
  runApp(MaterialApp(
    home: ImageToPdfPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ImageToPdfPage extends StatefulWidget {
  @override
  _ImageToPdfPageState createState() => _ImageToPdfPageState();
}

class _ImageToPdfPageState extends State<ImageToPdfPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = [];
  String? _outputFilePath;

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid && await Permission.storage.request().isGranted) {
      return;
    } else if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission required')),
      );
    }
  }

  Future<void> _createPdf() async {
    if (_imageFiles.isEmpty) return;

    final pdf = pw.Document();
    for (var imageFile in _imageFiles) {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
    }

    await _requestPermission();

    String fileName = "image_to_pdf_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
    if (Platform.isAndroid && (await _savePdfToDownloads(pdf, fileName))) {
      setState(() {
        _outputFilePath = "Saved to Downloads folder";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved in Downloads folder')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF')),
      );
    }
  }

  Future<bool> _savePdfToDownloads(pw.Document pdf, String fileName) async {
    if (Platform.isAndroid && (await _isScopedStorage())) {
      return await _saveToMediaStore(pdf, fileName);
    } else {
      return await _saveToDownloadsFolder(pdf, fileName);
    }
  }

  Future<bool> _isScopedStorage() async {
    return Platform.isAndroid && (await Platform.version).compareTo("10") >= 0;
  }

  Future<bool> _saveToDownloadsFolder(pw.Document pdf, String fileName) async {
    try {
      Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      if (!(await downloadsDir.exists())) {
        await downloadsDir.create(recursive: true);
      }
      File file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _saveToMediaStore(pw.Document pdf, String fileName) async {
    try {
      final data = await pdf.save();
      final path = '/storage/emulated/0/Download/$fileName';
      File file = File(path);
      await file.writeAsBytes(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to PDF Converter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Text("Pick Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _createPdf,
              icon: Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text("Create PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 20),
            _imageFiles.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFiles[index],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text("Image ${index + 1}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text("No images selected yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}
