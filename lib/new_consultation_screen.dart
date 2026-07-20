import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';

class NewConsultationScreen extends StatefulWidget {
  NewConsultationScreen ({super.key});

  @override
  State<NewConsultationScreen> createState () => _NewConsultationScreenState();
}

class _NewConsultationScreenState extends State<NewConsultationScreen>{
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try{
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxHeight: 1200,
        maxWidth: 1200,
        );
      if(pickedFile !=null){
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    } finally{
      setState(() => _isLoading = false);
    }
  }
  void _continueToValidation(){
    if(_selectedImage == null) return;
    Navigator.pushNamed(
      context, 
      AppRouter.imageQuality,
      arguments: {'imagePath': _selectedImage!.path},
      );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Image"),
        leading: BackButton(
          onPressed: (){
            // Confirm exit if image is selected
            if(_selectedImage !=null){
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: const Text("Discard Image?"),
                  content: const Text("Are you sure you want to go back? The captured image will be lost."),
                  actions: [
                    TextButton(
                      onPressed: ()=> Navigator.pop(context), 
                      child: Text("Cancel")),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }, 
                        child: const Text("Discard")
                        ),
                  ],
                )
                );
            } else{
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressIndicator(context),
            const SizedBox(height: 32,),
            Text(
              "Upload Lesion Image",
              style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8,),
              Text("For accurate analysis, ensure the photo is well-lit, in focus, and centered on the affected area.",
              style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24,),
              // Image Preview Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: _selectedImage == null ? Colors.grey.shade300 : AppConstants.primaryColor,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(),)
                    : _selectedImage !=null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            // Retake button overlay
                            Positioned(
                              top: 16,
                              right: 16,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  onPressed: () => setState(() => _selectedImage = null),
                                   icon: const Icon(Icons.close, color: Colors.white,),
                                   ),
                              ),
                              ),
                          ],
                        ),
                      )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey.shade400,),
                        const SizedBox(height: 16,),
                        Text("No image selected", style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                ),
              ),
              const SizedBox(height: 24,),
              // Actions Buttons
              if(_selectedImage == null) ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                   label: const Text("Capture Photo"),
                   ),
                   const SizedBox(height: 16,),
                   OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library), 
                    label: const Text("Select from Gallery"),
                    ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _continueToValidation,
                     child: const Text("Continue"),
                  ),
                ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildProgressIndicator(BuildContext context){
  return Row(
    children: [
      _buildStepIndicator(context, '1', true),
      _buildStepLine(context, false),
      _buildStepIndicator(context, '2', false),
      _buildStepLine(context, false),
      _buildStepIndicator(context, '3', false),
    ],
  );
}
Widget _buildStepIndicator(BuildContext context, String text, bool isActive){
  return Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
);
}
Widget _buildStepLine(BuildContext context, bool isActive){
  return Expanded(
    child: Container(
      height: 2,
      color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
      ),
    );
  }
} 