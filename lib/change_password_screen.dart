import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget{
  const ChangePasswordScreen({super.key});
  @override 
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>{
  final _formKey = GlobalKey<FormState>();

final TextEditingController currentPasswordController = TextEditingController();
final TextEditingController newPasswordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Create a strong password.",
                style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32,),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: ()=> setState(() => _obscureCurrent =!_obscureCurrent),
                      icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                  return "Current password is required";
                  }
                   return null;
                  },
              ),
                const SizedBox(height: 16,),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: ()=> setState(() => _obscureNew =!_obscureNew),
                      icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                   return "New password is required";
                  }
                if (value.length < 8) {
                 return "Password must be at least 8 characters";
                }
                return null;
                 },
                ),
                const SizedBox(height: 16,),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: ()=> setState(() => _obscureConfirm =!_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                  return "Please confirm password";
                  }
                  if (value != newPasswordController.text) {
                  return "Passwords do not match";
                  }
                  return null;
                 },
              ),
                const SizedBox(height: 32,),
                ElevatedButton(
                  onPressed: () async{
                    if(_formKey.currentState!.validate()){

                      final authProvider = Provider.of<AuthProvider>(context, listen:false);
                      final result =  await authProvider.changePassword(
                        currentPassword: currentPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                      );
                      if(!mounted) return;
                      if(result == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password updated successfully.")),
                      );
                      Navigator.pop(context);
                      } else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Enter Correct Cretentials.")),
                        );
                      }
                      
                      
                    }
                  }, child: const Text("Update Password"),
                  ),
              ],
            ),
          ),
        ),
      );
   }
}