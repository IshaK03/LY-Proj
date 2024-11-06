import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<File> _prescriptionImages = []; // Store the selected or captured images
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _prescriptionImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to capture image from camera
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _prescriptionImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    setState(() {
      _prescriptionImages.removeAt(index);
    });
  }

  // Function to retake an image (replace at specific index)
  Future<void> _retakeImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _prescriptionImages[index] = File(pickedFile.path);
      });
    }
  }

  // Show image in full screen with entire background blurred
  void _showFullScreenImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Fullscreen blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            // Image display
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Prescriptions"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4b6cb7), Color(0xff182848)],
            stops: [0, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _prescriptionImages.isEmpty
                  ? Image.asset(
                      'assets/images/prescriptionGraphic.png', // Placeholder image asset
                      height: 350,
                      fit: BoxFit.contain,
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _prescriptionImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0
                                ? 20.0
                                : 0, // Space for the first image
                            right: 10.0, // Space between images
                            top: 12,
                          ),
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () => _showFullScreenImage(
                                    _prescriptionImages[index]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      16), // Rounded corners
                                  child: Image.file(
                                    _prescriptionImages[index],
                                    height: 300,
                                    width: 250,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay,
                                          color: Colors.white),
                                      onPressed: () => _retakeImage(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),

            // Buttons arranged vertically with consistent width
            Column(
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan"),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center, // Center-aligns the text
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Upload From Gallery"),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center, // Center-aligns the text
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Confirm"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Images confirmed and uploaded!"),
                          backgroundColor:
                              Colors.green, // Green background for success
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center, // Center-aligns the text
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
