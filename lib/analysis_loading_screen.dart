import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
//import 'package:dermassist_fyp/providers/consultation_provider.dart';
import 'package:dermassist_fyp/models/consultation_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisLoadingScreen extends StatefulWidget{
  //final SymptomData? consultationData;
  //const AnalysisLoadingScreen({super.key, required this.consultationData});
  const AnalysisLoadingScreen({super.key});
  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();

}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> with SingleTickerProviderStateMixin{
  String _loadingMessage = "Uploading image and sysmtom data...";
  double _progressValue = 0.1;
  late AnimationController _animationController;

  @override
   void initState(){
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
      WidgetsBinding.instance.addPostFrameCallback((_){
        _startAnalysisProcess();
      });
      
   }

   @override
   void dispose(){
    _animationController.dispose();
    super.dispose();
   }

   Future<void> _startAnalysisProcess() async{
    _updateProgress(0.3, "Processing image features...");
    await Future.delayed(const Duration(seconds: 1));
    _updateProgress(0.5, "Running AI model...");

    
    try{
     //final result = await Provider.of<ConsultationProvider>(context, listen: false).analyzeLesion();

      // will be removed later
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String imageUrl = args['imageUrl'];
    final Map <String, dynamic>symptomData = Map<String, dynamic>.from(args['symptomData']) ;
    final String consultationId = args['consultationId'];

    _updateProgress(0.7, "Sending data to AI...");
    final response = await http.post(
      Uri.parse("http://192.168.1.13:3000/analyze"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "imageUrl": imageUrl,
        "symptomData": symptomData,
        //"consultationId": consultationId,
      }),
    );
    if(response.statusCode !=200){
      throw Exception("Server error: ${response.body}");
    }
    final data = jsonDecode(response.body);
    if(data['success']){
      final result = data['result'];
      // Result save to Firestore
       await FirebaseFirestore.instance
      .collection('consultations')
      .doc(consultationId)
      .set({
    'result': result,
    'status': 'completed',
  }, SetOptions(merge: true));
       _updateProgress(1.0, "Analysis complete!");
      await Future.delayed(const Duration(milliseconds: 500));
       // Navigate to results
      if(mounted){
        Navigator.pushReplacementNamed(
          context, 
          AppRouter.results,
          //arguments: {'result': result},
          arguments: data,
          );
      }
    } else{
      throw Exception(data['error']);
    }
               
    } catch(e){
      if(!mounted) return;
      //Navigate to Error screen
      Navigator.pushReplacementNamed(
        context, 
        AppRouter.error,
        arguments: {"message" : "Analysis failed: $e"},
        );
    }
  }
  void _updateProgress(double value, String message){
    if(mounted){
      setState(() {
        _progressValue = value;
        _loadingMessage = message;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController, 
                    builder: (context, child){
                      return Transform.scale(
                        scale: 1.0 + (_animationController.value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                //color: AppConstants.primaryColor,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.psychology_rounded,
                          size: 80,
                          color: AppConstants.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48,),
                  Text(
                    "AI Analysis in Progress",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16,),
                    Text(
                      _loadingMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48,),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12,),
                    Text(
                      '${(_progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor
                        ),
                    ),
                    const SizedBox(height: 32,),

                    // Disclaimer note
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Please do not close the app while the analysis is running.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12, 
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}