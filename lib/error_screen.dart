import 'package:flutter/material.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class ErrorScreen extends StatefulWidget{
  final String? message;
  const ErrorScreen({super.key, this.message});
  @override
  State<ErrorScreen> createState()=> _ErrorScreenState();
}
class _ErrorScreenState extends State<ErrorScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Error"),
        leading: IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRouter.main,(route) => false),
           icon: const Icon(Icons.close),
           ),
      ),
      body: SafeArea(
        child:SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset('assets/animations/error.json',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              ),
              const SizedBox(height: 24,),
              Text(
                "Oops, something went wrong!",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                
              ),
              const SizedBox(height: 16,),
              Text(
                widget.message ?? "An unexpected error occured. Please try again later.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 32,),
              ElevatedButton.icon(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                ),
                const SizedBox(height: 16,),
                OutlinedButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, AppRouter.main, (route)=> false);
                  }, 
                  child: const Text("Go to Home"),
                  ),
                  const SizedBox(height: 16,),
            ],
          ),
          ),
          
        ),
      ),
    );
  }
}

class NoInternetConnectionScreen extends StatelessWidget{
  const NoInternetConnectionScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset('assets/animations/nointernet.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
              ),
              const SizedBox(height: 24,),
              Text(
                "No Internet Connection",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16,),
              Text(
                "Please check your network settings and ensure you have an active internet connection to use DermAssist features.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48,),
              ElevatedButton.icon(
                onPressed: () async{
                  final result = await Connectivity().checkConnectivity();
                  if(result.contains(ConnectivityResult.mobile
                  )||
                  result.contains(ConnectivityResult.wifi)){
                    Navigator.pop(context);
                  } else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Still no internet connection!"),
                        ),
                      );
                  }

                },
                icon: const Icon(Icons.refresh),
                 label: const Text("Retry Connection"),
                 ),
            ],
          ),
          ),
          ),
    );
  }
}