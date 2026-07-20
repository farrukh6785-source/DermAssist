import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:dermassist_fyp/forgot_password_screen.dart';


class LoginScreen extends StatefulWidget{
  const LoginScreen ({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State <LoginScreen>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  



  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()){
      try{
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if(!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.main);
      } catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${e.toString()}")),
          );
      }
    }
  }
  void _googleLogin() async{
    try{
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();
      final success = await authProvider.signInWithGoogle();
      if((success == true) && mounted){
      Navigator.pushReplacementNamed(context, AppRouter.main);
      }
    } catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google sign-in failed. Please try agian.")),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context){
    final isLoading = context.watch<AuthProvider>().status == AuthStatus.authenticating;
    //final isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20,),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.asset("assets/images/logo.png",
                          height: 200,
                      ),
                ),
                const SizedBox(height: 24,),
                Text("Wellcome Back",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                ),
                Text(
                  "Sign in to continue using DermAssist",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30,),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Please enter your email";
                      if(!value.contains('@')) return "Please enter a valid email address";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16,),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }, 
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)
                        ),
                    ),
                    validator: (value){
                      if (value == null || value.isEmpty) return "Please enter your password";
                      if (value.length<6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),
                          ),
                          );

                        // Implement forgot password flow
                      }, 
                      child: const Text("Forgot Password?"),
                      ),
                    ),
                    const SizedBox(height: 24,),
                    // Login Button
                    ElevatedButton(
                      onPressed: isLoading  ? null : _login,
                        child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white,)
                        : const Text("Login", style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                    const SizedBox(height: 24,),
                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: Theme.of(context).textTheme.bodySmall, ),
                              ),
                              const Expanded(child: Divider()),
                      ],
                      ),
                      const SizedBox(height: 24,),

               // Google Login Button
               OutlinedButton.icon(
                onPressed: isLoading 
                ? null : 
                     _googleLogin,
                icon:  Image.asset("assets/images/google_logo.png", width: 30,height: 30,),
                 label: const Text("Continue with Google"),
                 ),
                const SizedBox(height: 20,),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, AppRouter.register);
                      }, 
                      child: const Text("Sign Up", 
                      style: TextStyle(fontWeight: FontWeight.bold),)
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