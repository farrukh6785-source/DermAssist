import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';

class HowToUseGuideScreen extends StatelessWidget {
  const HowToUseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use Guide'),
        backgroundColor: AppConstants.primaryColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to DermAssist AI 🤗',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryLight, 
                    ),
                ),

                const SizedBox(height: 16),

                Text(
                  '1. Capture or upload an image of the affected skin area.\n\n'
                  '2. Wait for the AI (MedGemma) to analyze the image and generate a report.\n\n'
                  '3. Review the AI-generated preliminary results and recommendations.\n\n'
                  '4. Consult a certified dermatologist for professional medical advice.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppConstants.textPrimaryLight, 
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
