import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  File? _convertedFile;
  bool _isConverting = false;
  String _statusMessage = "No file selected.";
  String? _fileContent;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);

      String? content;
      if (pickedFile.path.endsWith(".txt")) {
        content = await pickedFile.readAsString();
      } else if (pickedFile.path.endsWith(".png") || pickedFile.path.endsWith(".jpg")) {
        content = null; 
      } else {
        content = "Preview not supported for this file type.";
      }

      setState(() {
        _pickedFile = pickedFile;
        _fileContent = content;
        _convertedFile = null;
        _statusMessage = "File selected successfully.";
      });
    } else {
      setState(() {
        _statusMessage = "No file selected.";
      });
    }
  }

  Future<void> _convertFile(String format) async {
    if (_pickedFile == null) {
      setState(() {
        _statusMessage = "Please pick a file first.";
      });
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = "Converting to $format...";
    });

    try {
      await _requestPermissions();

      final String outputPath = await _getSavePath('converted_file.$format');
      final File outputFile = File(outputPath);

      await _pickedFile!.copy(outputFile.path);

      setState(() {
        _convertedFile = outputFile;
        _statusMessage = "File converted and saved successfully.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("File saved at: $outputPath"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return;
      }

      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception("Storage permission denied!");
      }
    } else if (Platform.isIOS) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception("Storage permission denied!");
      }
    }
  }

  Future<String> _getSavePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$filename";
  }

  Widget _buildFilePreview() {
    if (_pickedFile == null) {
      return const SizedBox.shrink();
    }

    if (_pickedFile!.path.endsWith(".txt")) {
      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        color: Colors.grey[200],
        child: Text(
          _fileContent ?? "Unable to read the file content.",
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else if (_pickedFile!.path.endsWith(".png") || _pickedFile!.path.endsWith(".jpg")) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: Image.file(
          _pickedFile!,
          height: 200,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return const Text(
        "Preview not supported for this file type.",
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Conversion')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick a File'),
              ),
              const SizedBox(height: 20),
              if (_pickedFile != null) ...[
                const Text("File Preview:", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFilePreview(),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _convertFile('pdf'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Convert to PDF'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _convertFile('docx'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Convert to DOCX'),
              ),
              const SizedBox(height: 20),
              if (_convertedFile != null) ...[
                const Text("Converted File:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _convertedFile!.path,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              const SizedBox(height: 20),
              if (_isConverting)
                const CircularProgressIndicator()
              else
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
