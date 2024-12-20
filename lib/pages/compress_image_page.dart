import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const CompressImagePage(),
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

    
    final directory = await getTemporaryDirectory();
    final compressedFilePath = '${directory.path}/compressed_image.jpg';

    final compressedFile = File(compressedFilePath)
      ..writeAsBytesSync(img.encodeJpg(compressedImage));

    setState(() {
      _compressedImage = compressedFile;
    });

    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image compressed and saved!')),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File path: $compressedFilePath')),
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
        title: const Text('Image Compression Example'),
        backgroundColor: Colors.deepPurple, 
      ),
      backgroundColor: Colors.purple[50], 
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              _originalImage != null
                  ? Column(
                      children: [
                        const Text('Original Image:', style: TextStyle(color: Colors.black)),
                        Image.file(_originalImage!, height: 200),
                      ],
                    )
                  : const Text('No image selected.', style: TextStyle(fontSize: 16, color: Colors.black)),

              const SizedBox(height: 20),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _widthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Width (default: 600)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height (optional)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

        
              _compressedImage != null
                  ? Column(
                      children: [
                        const Text('Compressed Image:', style: TextStyle(color: Colors.black)),
                        Image.file(_compressedImage!, height: 200),
                      ],
                    )
                  : const SizedBox(),

              const SizedBox(height: 20),

          
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, 
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              
              ElevatedButton(
                onPressed: _isCompressing ? null : _compressImage, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  elevation: 5, 
                ),
                child: _isCompressing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Compress Image',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
