
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget{
  const RegistrationScreen({super.key});
  @override 
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen>{
  final _formKey  = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose(){
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future <void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago default
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(),
      );
      if(picked != null && picked != _selectedDate){
        setState(() {
          _selectedDate = picked;
          _dobController.text = DateFormat("yyyy-MM-dd").format(picked);
        });
      }
  }
  void _handleRegistration() async {
    if(!_acceptedTerms){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms & conditions")),
        );
        return;
    }
    if(_formKey.currentState!.validate() && _selectedDate != null){
      
        final authProvider = Provider.of<AuthProvider> (context, listen: false);
        final errorMessage = await authProvider.registerWithEmailAndPassword(
         email:  _emailController.text.trim(),
         password:  _passwordController.text.trim(),
         fullName:  _nameController.text.trim(),
         dob:  _selectedDate!,
        );
        if(errorMessage == null){
          if(!mounted) return;
        // Show success then go to main screen
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:Text("User registrated successfully.")),
            );
        Navigator.pushReplacementNamed(context, AppRouter.main);
        } else {
          if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:Text("Registration failed: $errorMessage")),
            );
        }
      }
    }else if(_selectedDate == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your Date of Birth")),
        );
    }
  }

      @override
      Widget build(BuildContext context){
        final isLoading = context.watch<AuthProvider>().status == AuthStatus.authenticating;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Create Account"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Join DermAssist",
                    style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8,),
                    Text("Your intelligent assistant for dematology health",
                    style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 32,),

                    // Full Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Please enter your name";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16,),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Please enter an email";
                        if(!value.contains("@")) return "Enter a valid email address";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16,),
                    // Date of Birth Field (Picker)
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: ()=> _selectDate(context),
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: ()=>setState(() => _obscurePassword = !_obscurePassword),
                           icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                           ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Enter a password";
                        if(value.length < 8) return "Password must be at leat 8 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16,),
                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: ()=>setState(() => _obscureConfirm = !_obscureConfirm),
                           icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                           ),
                      ),
                      validator: (value){
                        if(value != _passwordController.text) return "Password do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24,),
                    // Terms Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms, 
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value)=> setState(()=> _acceptedTerms = value ?? false),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan (
                                text: "I agree to the ",
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(text: "Terms & Conditions",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                  const TextSpan(text: " and "),
                                  TextSpan(text: "Privacy Policy",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ]
                              ),
                              ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 32,),
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleRegistration,
                       child: isLoading
                       ? const CircularProgressIndicator(color: Colors.white)
                       : const Text ("Sign UP"),
                       ),
                       const SizedBox(height: 24,),
                       // Login Link
                       Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context); // Go back to loging 
                            }, 
                            child: const Text ("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                       ),
                     ],
                  ),
                ),
            ),
            ),
        );
      }
    }

