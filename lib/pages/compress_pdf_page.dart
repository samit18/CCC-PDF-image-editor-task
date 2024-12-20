import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
      final params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
      );

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
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = "${tempDir.path}/compressed.pdf";

      final pdfBytes = await _selectedPdf!.readAsBytes();
      final PdfDocument pdfDoc = PdfDocument(inputBytes: pdfBytes);

      for (int i = 0; i < pdfDoc.pages.count; i++) {
        final page = pdfDoc.pages[i];

        final pageSize = page.size;
        double scaleX = _width / pageSize.width;
        double scaleY = _length / pageSize.height;

        page.graphics.scale(scaleX, scaleY);
      }

      final compressedBytes = await pdfDoc.save();
      pdfDoc.dispose();

      final compressedFile = File(outputPath)..writeAsBytesSync(compressedBytes);

      setState(() {
        _compressedPdf = compressedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF compressed and resized successfully!")),
      );

      _saveCompressedPdf(compressedFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error compressing file: $e")),
      );
    }
  }

  Future<void> _saveCompressedPdf(File compressedFile) async {
    try {
      final params = SaveFileDialogParams(
        fileName: "compressed.pdf",
        data: await compressedFile.readAsBytes(),
      );

      final savePath = await FlutterFileDialog.saveFile(params: params);

      if (savePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF saved successfully at: $savePath")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving file: $e")),
      );
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
        title: Text("Compressed PDF Page", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickPdf,
              child: Text("Pick PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(
                labelText: 'Length (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _length = double.tryParse(value) ?? 210;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _widthController,
              decoration: InputDecoration(
                labelText: 'Width (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _width = double.tryParse(value) ?? 297;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (optional, mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _height = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _compressPdf,
              child: Text("Compress PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28)),
            ),
            SizedBox(height: 16),
            Expanded(child: _buildPdfViewer(_compressedPdf ?? _selectedPdf)),
          ],
        ),
      ),
    );
  }
}

extension on PdfGraphics {
  void scale(double scaleX, double scaleY) {}
}
