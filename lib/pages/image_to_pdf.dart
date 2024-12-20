import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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

  
  Future<void> _createPdf() async {
    if (_imageFiles.isEmpty) return;

    final pdf = pw.Document();

    
    for (var imageFile in _imageFiles) {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ));
    }

    
    final directory = await getApplicationDocumentsDirectory();
    final outputFile = File('${directory.path}/image_to_pdf.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    setState(() {
      _outputFilePath = outputFile.path;
    });

    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfPath: _outputFilePath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Convert Images to PDF", style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pick Images Button
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.photo_library),
              label: Text("Pick Images"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _createPdf,
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Create PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_imageFiles.isNotEmpty)
              Expanded(
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
                        title: Text("Image ${index + 1}",
                            style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: Text("No images selected yet", style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PdfViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View PDF"),
        backgroundColor: Colors.deepPurple,
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
