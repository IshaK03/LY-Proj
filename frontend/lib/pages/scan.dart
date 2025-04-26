import 'package:flutter/material.dart';
import 'package:frontend/reusable_widgets/drawer.dart';
import 'package:frontend/utils/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? prescriptionImage; // Store the selected or captured images
  final ImagePicker _picker = ImagePicker();
  final ApiService apiService = ApiService();
  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        prescriptionImage = File(pickedFile.path);
      });
    }
  }

  // Function to capture image from camera
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        prescriptionImage = File(pickedFile.path);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage() {
    setState(() {
      prescriptionImage = null;
    });
  }

  // Function to retake an image (replace at specific index)
  Future<void> _retakeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        prescriptionImage = File(pickedFile.path);
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
        centerTitle: true,
        backgroundColor: Color.fromRGBO(76, 123, 238, 1),
      ),
      drawer: const CustomDrawer(),
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
              child: prescriptionImage != null
                  ? Stack(
                      children: [
                        InkWell(
                          onTap: () => _showFullScreenImage(prescriptionImage!),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              prescriptionImage!,
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
                                onPressed: _retakeImage,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: _removeImage,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Image.asset(
                      'assets/images/prescriptionGraphic.png',
                      height: 350,
                      fit: BoxFit.contain,
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
                    icon:
                        const Icon(Icons.camera_alt, color: Colors.blueAccent),
                    label: const Text(
                      "Scan",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center, // Center-aligns the text
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, color: Colors.blueAccent),
                    label: const Text(
                      "Upload From Gallery",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center, // Center-aligns the text
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.blueAccent),
                    label: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      if (prescriptionImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select an image first!"),
                            backgroundColor:
                                Colors.red, // Red background for error
                          ),
                        );
                        return;
                      }
                      var medicationReminders = await apiService
                          .getMedicationReminders(prescriptionImage!);
                      debugPrint("Medication reminders: $medicationReminders");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Images confirmed and uploaded!"),
                          backgroundColor:
                              Colors.green, // Green background for success
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
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
