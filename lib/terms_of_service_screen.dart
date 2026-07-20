import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '''Terms of Service,
              
      Last updated: April 2026

   1. Acceptance of Terms
      By accessing or using DermAssist AI, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.

    2. Medical Disclaimer
      DermAssist AI is an educational tool that provides preliminary analysis using artificial intelligence. It DOES NOT provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for any medical condition or concern. You should never disregard professional medical advice or delay in seeking it because of information provided by this application.

    3. User Accounts and Data
      You are responsible for maintaining the confidentiality of your account credentials. You also agree to provide accurate information and ensure that images you upload are yours or you have permission to upload them.

    4. Limitation of Liability
      To the fullest extent permitted by applicable law, DermAssist AI and its creators shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly as a result of using this app.

    5. Modifications to the Service
      We reserve the right to modify or discontinue, temporarily or permanently, the service with or without notice.

    6. Final Year Project Disclaimer
      This application is developed as a final year university project and is currently in a prototype phase. Reliability of results may vary.
      ''',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black, 
              ),
            ),
          ),
        ),
      ),
    );
  }
}
