import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditPdfPage extends StatefulWidget {
  const EditPdfPage({super.key});

  @override
  _EditPdfPageState createState() => _EditPdfPageState();
}

class _EditPdfPageState extends State<EditPdfPage> {
  String? selectedPdfPath;
  bool isPdfLoaded = false;
  bool isProcessing = false;
  bool cropRequested = false;

  double? cropTop;
  double? cropLeft;
  double? cropWidth;
  double? cropHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit PDF'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Pick an Existing PDF'),
              ),
              const SizedBox(height: 20),
              if (isPdfLoaded) ...[
                ElevatedButton(
                  onPressed: _addTextToPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Add Text to PDF'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _requestCropDimensions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Crop PDF Page'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openEditedPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Open Edited PDF'),
                ),
              ],
              if (isProcessing) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedPdfPath = result.files.single.path!;
        isPdfLoaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Loaded: ${result.files.single.name}')),
      );
    }
  }

  Future<void> _addTextToPdf() async {
    String userInput = await _getUserInput();
    if (userInput.isEmpty) return;

    setState(() => isProcessing = true);

    try {
      final File file = File(selectedPdfPath!);
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

      final PdfPage page = document.pages[0];
      page.graphics.drawString(
        userInput,
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: const Rect.fromLTWH(50, 50, 500, 30),
      );

      final List<int> updatedBytes = await document.save();
      await file.writeAsBytes(updatedBytes);

      document.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text added to PDF!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _requestCropDimensions() async {
    double top = 0, left = 0, width = 0, height = 0;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Crop Dimensions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Top (Y-coordinate)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => top = double.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Left (X-coordinate)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => left = double.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                onChanged: (value) => width = double.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                onChanged: (value) => height = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cropTop = top;
                  cropLeft = left;
                  cropWidth = width;
                  cropHeight = height;
                  cropRequested = true;
                });
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditedPdf() async {
    if (cropRequested) await _cropPdf();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerPage(pdfFilePath: selectedPdfPath!)),
    );
  }

  Future<void> _cropPdf() async {
    setState(() => isProcessing = true);

    try {
      final File file = File(selectedPdfPath!);
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

      final PdfPage originalPage = document.pages[0];
      final PdfDocument croppedDocument = PdfDocument();

      // Correcting the cropping process
      final PdfPage newPage = croppedDocument.pages.add();

      // Use Offset for positioning and drawing the template
      final PdfTemplate template = originalPage.createTemplate();
      newPage.graphics.drawPdfTemplate(
        template,
        Offset(cropLeft!, cropTop!),  // Correct the use of Offset for drawing
        Size(cropWidth!, cropHeight!),
      );

      final List<int> updatedBytes = await croppedDocument.save();
      await file.writeAsBytes(updatedBytes);

      document.dispose();
      croppedDocument.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Page Cropped Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isProcessing = false;
        cropRequested = false;
      });
    }
  }

  Future<String> _getUserInput() async {
    String input = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Text to Add'),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: const InputDecoration(hintText: 'Type your text here...'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Submit')),
          ],
        );
      },
    );
    return input;
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfFilePath;

  const PdfViewerPage({super.key, required this.pdfFilePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer'), backgroundColor: Colors.deepPurple),
      body: PDFView(filePath: pdfFilePath),
    );
  }
}
