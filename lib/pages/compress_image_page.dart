import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Compression',
      theme: ThemeData(
        dialogBackgroundColor: Colors.deepPurple,
      ),
      home: const CompressImagePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompressImagePage extends StatefulWidget {
  const CompressImagePage({Key? key}) : super(key: key);

  @override
  _CompressImagePageState createState() => _CompressImagePageState();
}

class _CompressImagePageState extends State<CompressImagePage> {
  File? _originalImage;
  File? _compressedImage;
  bool _isCompressing = false;

  final picker = ImagePicker();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _originalImage = File(pickedFile.path);
        _compressedImage = null;
      });
    }
  }

  Future<void> _compressImage() async {
    if (_originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image first!')),
      );
      return;
    }

    setState(() {
      _isCompressing = true;
    });

    try {
      final width = int.tryParse(_widthController.text) ?? 600;
      final height = int.tryParse(_heightController.text);
      final imageBytes = await _originalImage!.readAsBytes();
      final img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) {
        throw Exception('Could not decode the image.');
      }

      final compressedImage = height != null
          ? img.copyResize(image, width: width, height: height)
          : img.copyResize(image, width: width);

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final compressedFilePath = '${directory.path}/compressed_image_$timestamp.jpg';
      final compressedFile = File(compressedFilePath)..writeAsBytesSync(img.encodeJpg(compressedImage));

      setState(() {
        _compressedImage = compressedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to Download folder: compressed_image_$timestamp.jpg')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error compressing image: $e')),
      );
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compression', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade200, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_originalImage != null)
                Column(
                  children: [
                    const Text('Original Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_originalImage!, height: 200),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Width (default: 600)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('Pick Image'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compressImage,
                icon: const Icon(Icons.compress, color: Colors.white),
                label: _isCompressing ? const CircularProgressIndicator(color: Colors.white) : const Text('Compress Image'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
