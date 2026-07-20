import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              '''Privacy Policy

Last updated: April 2026

1. Information We Collect
We collect personal information such as your basic profile details, email address, and the medical skin condition images you upload to the platform for AI analysis. We may also collect usage data to monitor app performance.

2. How We Use Your Information
Your information and uploaded images are primarily used to provide the AI screening service via the MedGemma model. We also use this data to improve our algorithms, fix bugs, and provide customer support.

3. Data Security
We implement robust, industry-standard security measures, including data encryption in transit and at rest using Firebase and Google Cloud, to secure your health-related data. However, no electronic transmission is 100% secure.

4. Data Sharing and Third Parties
We do not sell your personal information or medical images to third parties. Data is shared only with trusted cloud infrastructure providers (like Google Vertex AI) strictly for processing your requests.

5. Data Retention
We retain your usage data and images only as long as necessary to provide the service or as required by law. You may request account and data deletion at any time through the support channels.
''',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black, // consistent dark text
              ),
            ),
          ),
        ),
      ),
    );
  }
}
