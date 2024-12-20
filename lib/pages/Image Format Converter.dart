import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Format Converter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: ImageConverterPage(),
    );
  }
}

class ImageConverterPage extends StatefulWidget {
  @override
  _ImageConverterPageState createState() => _ImageConverterPageState();
}

class _ImageConverterPageState extends State<ImageConverterPage> {
  File? _originalImage;
  File? _convertedImage;

  final picker = ImagePicker();

  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _originalImage = File(pickedFile.path);
        _convertedImage = null; 
      });
    }
  }


  Future<void> _convertToPng() async {
    if (_originalImage == null) return;

    final bytes = await _originalImage!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      print("Failed to decode image.");
      return;
    }

    
    final pngBytes = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final convertedImagePath = '${directory.path}/converted_image.png';
    final convertedFile = File(convertedImagePath);
    await convertedFile.writeAsBytes(pngBytes);

    setState(() {
      _convertedImage = convertedFile;
    });

    print('Image saved to $convertedImagePath');
  }


  Future<void> _convertToJpg() async {
    if (_originalImage == null) return;

    
    final bytes = await _originalImage!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      print("Failed to decode image.");
      return;
    }

    
    final jpgBytes = img.encodeJpg(image);
    final directory = await getApplicationDocumentsDirectory();
    final convertedImagePath = '${directory.path}/converted_image.jpg';
    final convertedFile = File(convertedImagePath);
    await convertedFile.writeAsBytes(jpgBytes);

    setState(() {
      _convertedImage = convertedFile;
    });

    print('Image saved to $convertedImagePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Format Converter'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Pick an Image', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_originalImage != null) ...[
                const Text("Original Image:"),
                Image.file(_originalImage!, width: 200, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _convertToPng,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Convert to PNG', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _convertToJpg,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Convert to JPG', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_convertedImage != null) ...[
                const Text("Converted Image:"),
                Image.file(_convertedImage!, width: 200, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text("Saved to: ${_convertedImage!.path}"),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
