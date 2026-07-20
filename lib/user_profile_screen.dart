import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget{
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _userProfileScreenState();
}
class _userProfileScreenState extends State<UserProfileScreen>{

  void _handleLogout(BuildContext context) async{
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
             child: const Text("Cancel")),
             TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout"),
              style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
              ),
            ],
      )
    );
    if(confirm == true){
      if(!context.mounted) return;
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      if(!context.mounted) return;
      //Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context){
    final user = context.watch<AuthProvider>().user;
    if(user == null){
      return const Center (
        child: CircularProgressIndicator(),
        );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user.profilePhotoUrl !=null
                        ? NetworkImage(user.profilePhotoUrl!)
                        : null,
                        child: user.profilePhotoUrl == null
                        ? const Icon(Icons.person, size: 80,
                        color: AppConstants.primaryColor,)
                        : null,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),

                        ),
                        child: IconButton(
                          onPressed: (){
                            Navigator.pushNamed(context, AppRouter.editProfile);
                          }, icon: Icon(Icons.edit, color: Colors.white, size: 30,),
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16,),
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32,),
            // Personal Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                  _buildInfoRow(Icons.cake_outlined, 'Age', '${user.age} Years Old'),
                  const Divider(),
                  _buildInfoRow(
                    Icons.calendar_month_outlined,
                    'Date of Birth',
                    DateFormat('MMMM dd, yyyy').format(user.dateOfBirth)
                  ),
                  const Divider(),
                  _buildInfoRow(Icons.location_on_outlined, 'Location',
                   user.location.isNotEmpty
                   ? user.location
                  : 'Not Specified'
),
          ],
         ),
        ),
      ),
      const SizedBox(height: 24,),
      Text("Settings & Preferences",
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.left,
      ),
      const SizedBox(height: 12,),
      Card(
        child: Column(
          children: [
            _buildSettingsTile(
              context,
              Icons.percent_rounded,
              "Edit Profile",
              AppRouter.editProfile,
            ),
            const Divider(height: 1,),
            _buildSettingsTile(
              context,
              Icons.lock_outline,
              "Change Password",
              AppRouter.changePassword,
              ),
              const Divider(height: 1,),
              _buildSettingsTile(
                context,
                Icons.security_outlined,
                'Privacy & Data Settings',
                AppRouter.privacySettings,
                ),
                const Divider(height: 1,),
                _buildSettingsTile(
                  context,
                  Icons.settings_outlined,
                  'App Settings',
                  AppRouter.settings,
                  ),
                  const Divider(height: 1,),
                  _buildSettingsTile(
                    context,
                    Icons.help_outline,
                    "About & Help",
                    AppRouter.about,
                    ),
                 ],
             ),
          ),
          const SizedBox(height: 32,),
          // Logout Button
          OutlinedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: Icon(Icons.logout_rounded, color: AppConstants.errorColor,),
            label: const Text("Log Out", style: TextStyle(color: AppConstants.errorColor),),
            style: OutlinedButton.styleFrom(
              side:  const BorderSide(color: AppConstants.errorColor),
            ),
          ),
          const SizedBox(height: 24,),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20,),
          const SizedBox(width: 16,),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            ),
          ),
           const SizedBox(width: 10),
          
          
          Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
           
          ),
        ),
        ],
      ),
    );
  }
  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String routePath){
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppConstants.primaryColor,),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey,),
      onTap: () => Navigator.pushNamed(context, routePath),
    );
  }
}