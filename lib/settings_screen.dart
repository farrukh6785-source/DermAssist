import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:dermassist_fyp/constants.dart';

class SettingsScreen extends StatefulWidget{
  const SettingsScreen ({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context){
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Appearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ),
            ListTile(
              title: const Text("Theme"),
              subtitle: Text(themeProvider.themeMode == ThemeMode.system
              ? "System Default"
              : (themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode')),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                underline: const SizedBox(),
                onChanged: (ThemeMode? newMode){
                  if(newMode != null){
                    themeProvider.setThemeMode(newMode);
                  }
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text("System"),),
                  DropdownMenuItem(value: ThemeMode.light, child: Text("Light"),),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark"),),
                ],
              ),
            ),
          const Divider(height: 32,),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Notifications", 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),),
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text("Analysis results and reminders"),
              value: _pushNotifications, 
              activeColor: AppConstants.primaryColor,
              onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              SwitchListTile(
                title: const Text("Email Notifications"),
                subtitle: const Text("Weekly reports and account alerts"),
                value: _emailNotifications,
                activeColor: AppConstants.primaryColor,
                onChanged:(val) => setState(()=> _emailNotifications = val) ,
                ),
                const Divider(height: 32,),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Storage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text("Clear Cache"),
                    subtitle: const Text("Free up space by removing temporary image files (42 MB)"),
                    onTap: (){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Cache cleared successfully")),
                      );
                    },
                  ),
               ],
             ),
          );
        }
    }