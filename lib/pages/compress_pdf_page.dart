import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';

class CompressedPdfPage extends StatefulWidget {
  @override
  _CompressedPdfPageState createState() => _CompressedPdfPageState();
}

class _CompressedPdfPageState extends State<CompressedPdfPage> {
  File? _selectedPdf;
  File? _compressedPdf;
  double _length = 210;
  double _width = 297;
  double _height = 0.0;

  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Future<void> _pickPdf() async {
    try {
      final params = OpenFileDialogParams(dialogType: OpenFileDialogType.document);
      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath != null) {
        setState(() {
          _selectedPdf = File(filePath);
          _compressedPdf = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
      );
    }
  }

  Future<void> _compressPdf() async {
    if (_selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No PDF selected to compress.")),
      );
      return;
    }

    try {
      await _checkAndRequestPermission();
      Directory? downloadsDirectory = await getExternalStorageDirectory();
      String outputPath = "${downloadsDirectory!.path}/compressed.pdf";
      
      final pdfBytes = await _selectedPdf!.readAsBytes();
      final PdfDocument pdfDoc = PdfDocument(inputBytes: pdfBytes);

      for (int i = 0; i < pdfDoc.pages.count; i++) {
        final page = pdfDoc.pages[i];
        final pageSize = page.size;
        double scaleX = _width / pageSize.width;
        double scaleY = _length / pageSize.height;
        if (_height > 0) {
          scaleY = _height / pageSize.height;
        }
        page.graphics.scale(scaleX, scaleY);
      }

      final compressedBytes = await pdfDoc.save();
      pdfDoc.dispose();

      final compressedFile = File(outputPath)..writeAsBytesSync(compressedBytes);
      setState(() {
        _compressedPdf = compressedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF compressed and saved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error compressing file: $e")),
      );
    }
  }

  Future<void> _checkAndRequestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return;
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied. Enable storage access in settings.")),
        );
        throw Exception("Storage permission denied");
      }
    }
  }

  Widget _buildPdfViewer(File? file) {
    if (file == null) return Center(child: Text("No PDF selected or generated."));
    return PDFView(
      filePath: file.path,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Compressor", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text("Pick PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 16),
            _buildTextField("Length (mm)", _lengthController, (value) => _length = double.tryParse(value) ?? 210),
            SizedBox(height: 16),
            _buildTextField("Width (mm)", _widthController, (value) => _width = double.tryParse(value) ?? 297),
            SizedBox(height: 16),
            _buildTextField("Height (optional, mm)", _heightController, (value) => _height = double.tryParse(value) ?? 0.0),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _compressPdf,
              icon: Icon(Icons.compress, color: Colors.white),
              label: Text("Compress PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 16),
            Expanded(child: _buildPdfViewer(_compressedPdf ?? _selectedPdf)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}

extension on PdfGraphics {
  void scale(double scaleX, double scaleY) {}
}
