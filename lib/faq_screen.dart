import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: AppConstants.primaryColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ExpansionTile(
                title: Text(
                  'Is DermAssist AI a replacement for a doctor?',
                  style: TextStyle(
                    color: AppConstants.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'No, DermAssist AI provides preliminary screening based on AI. It is not a substitute for professional medical diagnosis.',
                      style: TextStyle(
                        color: AppConstants.textPrimaryLight,
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),

              ExpansionTile(
                title: Text(
                  'How accurate is the AI?',
                  style: TextStyle(
                    color: AppConstants.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Our model is powered by MedGemma and is trained on robust dermatological datasets to provide high accuracy, but it can still make mistakes. Always consult a healthcare professional for a final diagnosis.',
                      style: TextStyle(
                        color: AppConstants.textPrimaryLight,
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),

              ExpansionTile(
                title: Text(
                  'Is my data secure?',
                  style: TextStyle(
                    color: AppConstants.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Yes, we prioritize your privacy and ensure your data and images are securely stored and processed in encrypted servers.',
                      style: TextStyle(
                        color: AppConstants.textPrimaryLight,
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
