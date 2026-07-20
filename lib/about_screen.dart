import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';
import 'guide_screen.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';


class AboutHelpScreen extends StatelessWidget{
  const AboutHelpScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("About & Help"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                 Image.asset("assets/images/logo.png",
              width: 160,
              height: 160,
              fit: BoxFit.cover,),
              const SizedBox(height: 10,),
              //Text(AppConstants.appName,
             // style: Theme.of(context).textTheme.headlineMedium,),
              Text("Version ${AppConstants.appVersion}",style: const TextStyle(color: Colors.grey),)
              ],
            ),
          ),
          const Divider(height: 2,),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Help & Support",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold, 
              color: AppConstants.textPrimaryLight
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text("How to Use Guide"),
          trailing: const Icon(Icons.chevron_right),
          onTap: (){
            Navigator.push(context, 
            MaterialPageRoute(builder:  (context) => const HowToUseGuideScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.question_answer_outlined),
          title: const Text("FAQ"),
          trailing: const Icon(Icons.chevron_right),
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqScreen()),
              );

          },
        ),
        ListTile(
          leading: const Icon(Icons.support_agent_outlined),
          title: const Text("Contact Support"),
          trailing: Icon(Icons.chevron_right),
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
              );

          },
        ),
        const Divider(height: 20,),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Legal", 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryLight),
          ),
          ),
          ListTile(
            title: const Text("Terms of Service"),
            trailing: const Icon(Icons.chevron_right),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
              );

            },
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.chevron_right),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 32,),
          const Text(
            'Final Year Project\nDeveloped Arshad Ali for academic purposes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 32),
        ],
      ),
    
    );
  }
}