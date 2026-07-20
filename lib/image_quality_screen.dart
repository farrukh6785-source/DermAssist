import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/consultation_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ImageQualityValidationScreen extends StatefulWidget {
  final String? imagePath;

  const ImageQualityValidationScreen({super.key, required this.imagePath});

  @override
  State<ImageQualityValidationScreen> createState() => _ImageQualityValidationScreenState();
}

class _ImageQualityValidationScreenState extends State<ImageQualityValidationScreen> {
  bool _isValidating = true;
  bool _passedQuality = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _runValidation();
    });
    
  }

  Future<void> _runValidation() async {
    if (widget.imagePath == null) {
      setState(() {
        _isValidating = false;
        _passedQuality = false;
        _errorMessage = 'No image provided.';
      });
      return;
    }

    // Set image to provider
    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    final file = File(widget.imagePath!);
    provider.setImage(file);

    try {
      // Run mocked quality validation pipeline from provider
      final passed = await provider.validateImageQuality();
      
      if (!mounted) return;

        setState(() {
          _isValidating = false;
          _passedQuality = passed;
          if (!passed) {
            _errorMessage = 'The image is too blurry or has poor lighting. Please ensure the lesion is clearly visible.';
          }
        });
      
    } catch (e) {
      if (!mounted) return;
        setState(() {
          _isValidating = false;
          _passedQuality = false;
          _errorMessage = 'Validation error: $e';
        });
      
    }
  }

  /*void _onContinue() {
    Navigator.pushNamed(
      context, 
      AppRouter.symptomInput,
      arguments: {'imagePath': widget.imagePath},
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConsultationProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Check'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProgressIndicator(context),
                    const SizedBox(height: 32),
                 Text(
                'AI Image Analysis',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
                 Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: _isValidating 
                              ? Colors.grey.shade300 
                              : (_passedQuality ? AppConstants.successColor : AppConstants.errorColor),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius - 3),
                        child: widget.imagePath != null
                            ? Image.file(
                                File(widget.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    // Status Output
                    if (_isValidating)
                      Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Checking image quality...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text('Scanning for blur, glare, and resolution'),
                        ],
                      )
                    else if (_passedQuality)
                      Column(
                        children: [
                          const Icon(Icons.check_circle, color: AppConstants.successColor, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Quality Status: Pass',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppConstants.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('The image is clear enough for AI analysis.'),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Icon(Icons.error, color: AppConstants.errorColor, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Quality Status: Fail',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppConstants.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ]
                      
            
                  ),
                ),
              ),
              // Progress Header
               if (provider.isUploading) 
             Column(
            children: [
            const SizedBox(height: 20),
            LinearProgressIndicator(
            value: provider.uploadProgress,
            ),
            const SizedBox(height: 10),
            Text(
            "Uploading Image... ${(provider.uploadProgress * 100).toStringAsFixed(0)}%",
          ),
        ],
       ),
        const SizedBox(height: 10,),
          // Actions
                if (!_isValidating) ...[
                if (_passedQuality)
                  ElevatedButton(
                    onPressed: provider.isUploading 
                    ? null 
                    : () async{
                      print("BUTTON CLICKED");

                    //final provider = Provider.of<ConsultationProvider>(context, listen: false);
                      if(!mounted) return;
                      //WidgetsBinding.instance.addPostFrameCallback((_){
                        
                        try{
                          final userId = FirebaseAuth.instance.currentUser!.uid;
                          final result = await provider.processImageAndCreateConsultation(userId);
                          final imageUrl = result['imageUrl'];
                          final consultationId = result['consultationId'];
                          
                          if(!mounted) return;
                           Navigator.pushNamed(
                            context, 
                            AppRouter.symptomInput,
                              arguments: {
                                'imageUrl': imageUrl,
                                'consultationId': consultationId,
                        },
                      );
                        
                      } catch(e){
                       
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                        );
                      }
                       
                      },
                    
                    child: const Text('Continue'),
                  )
              
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.errorColor,
                    ),
                    child: const Text('Retake Photo'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Row(
      children: [
        _buildStepIndicator(context, '1', true),
        _buildStepLine(context, true),
        _buildStepIndicator(context, '2', true),
        _buildStepLine(context, false),
        _buildStepIndicator(context, '3', false),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, String text, bool isActive) {
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

  Widget _buildStepLine(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
      ),
    );
  }
}
