import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override 
  State<PrivacySettingsScreen> createState () => _PrivacySettingsScreenState();
}
class _PrivacySettingsScreenState extends State<PrivacySettingsScreen>{
  bool _shareDataForResearch = false;
  bool _storeImagesInCloud =true;
  String _retentionPeriod = '1 Year';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
        "Privacy & Data"
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Data Consent Management",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Store Images in Cloud"),
            subtitle: const Text("Enables cross-device syncing and history"),

            value: _storeImagesInCloud, 
            activeColor: AppConstants.primaryColor,
            onChanged: (val) => setState(() => _storeImagesInCloud = val),
            ),
             SwitchListTile(
            title: const Text("share Data for Research"),
            subtitle: const Text("Allow anonymized data to improve AI models"),

            value: _shareDataForResearch, 
            activeColor: AppConstants.primaryColor,
            onChanged: (val) => setState(() => _shareDataForResearch = val),
            ),
            const Divider(height: 32,),
            ListTile(
              title: const Text("Data Retention Period"),
              subtitle: Text('Current: $_retentionPeriod'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: (){
                // Show dropdown sheet
                showModalBottomSheet(
                context: context, 
                builder:(context){
                  final options = ['3 Months', '6 Months', '1 Year', '2 Years'];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option){
                      return ListTile(
                        title: Text(option),
                        onTap: (){
                          setState(() {
                            _retentionPeriod = option;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
                );
              },
            ),
            const Divider(height: 32,),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Your Data Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text("Download My Data"),
              onTap: () async {
                // Trigger data archive export
                try{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Preparing your data export..."),
                    ),
                );
                final callable = FirebaseFunctions.instance.httpsCallable('exportUserData');
                await callable.call(
                  {
                    'userId': context.read<AuthProvider>().user!.id,
                    'email': context.read<AuthProvider>().user!.email,
                  }
                );
               // await Future.delayed(const Duration(seconds: 2));
                if(!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data sent to your email."),
                    ),
                );
              } catch(e){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
              },
            ),
           ListTile(
            leading: const Icon(Icons.delete_forever, color: AppConstants.errorColor,),
            title: const Text("Delete Account", style: TextStyle(color: AppConstants.errorColor),
            ),
            onTap: () async {
            // Confirm deletion
            final confirm = await showDialog<bool>(
              context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Delete Account"),
                content: const Text(
                  "This action is permanent and cannot be undone. Are you sure?",
                 ),
                 actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                     child: const Text("Cancel"),
                     ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true), 
                    child: const Text("Delete"),
                    ),
                 ],
              ),
            );
            if(confirm == true){
              // Call delete account API/Firebase delete
              if(!context.mounted) return;
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final result = await authProvider.deleteAccount();
              if(!context.mounted) return;
              if(result == null){
                 ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Account deleted successfully."
                  ),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
            } else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result)),
                );
            }
          }
            },
           ), 
        ],
      ),
    );
  }
}