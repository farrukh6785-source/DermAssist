import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
//import 'package:dermassist_fyp/models/consultation_model.dart';
import 'package:dermassist_fyp/providers/consultation_provider.dart';

class ResultsDiagnosisScreen extends StatefulWidget {
  //final ConsultationResult? resultData;
  //const ResultsDiagnosisScreen({super.key, required this. resultData});
  final Map<String, dynamic> resultData;
  const ResultsDiagnosisScreen({super.key, required this.resultData});

  @override
  State<ResultsDiagnosisScreen> createState() => _ResultsDiagnosisScreenState();
}

class _ResultsDiagnosisScreenState extends State<ResultsDiagnosisScreen>{
  //late ConsultationResult _result;
  late Map<String, dynamic> _result;
  bool _hasAcceptedDisclaimer = false;
  late String consultationId;

  @override
  void initState(){
    super.initState();
    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    consultationId = provider.consultationId ?? "";
    try {
      // 1. Extract raw data
      dynamic rawData = widget.resultData.containsKey('result')
          ? widget.resultData['result']
          : widget.resultData;

      // 2. Decode and Assign correctly
      if (rawData == null || (rawData is Map && rawData.isEmpty)) {
        _result = {
          'risk_level': "Unknown",
          'possible_diagnoses': [],
          'ai_reasoning': "Data unavailable"
        };
      } else if (rawData is String) {
        // Decode the string and cast it as a Map
        _result = Map<String, dynamic>.from(jsonDecode(rawData));
      } else if (rawData is Map) {
        // If it's already a map, just cast it
        _result = Map<String, dynamic>.from(rawData);
      } else {
        throw "Unsupported data format";
      }
    } catch (e) {
      debugPrint("Error in initState: $e");
      _result = {
        'risk_level': 'Error',
        'possible_diagnoses': [],
        'ai_reasoning': 'Failed to load analysis.'
      };
    }
    

   /* if(widget.resultData != null){
      _result = widget.resultData!;

    } else{
      _result = Provider.of<ConsultationProvider>(context, listen: false).currentResult!;
     }*/

    WidgetsBinding.instance.addPostFrameCallback((_){
      _showSafetyDisclaimer();
     });
  }
  void _showSafetyDisclaimer(){
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildDisclaimerModal(),
      );
  }
  Widget _buildDisclaimerModal(){
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded,
            size: 64,
            color: AppConstants.warningColor,
            ),
            const SizedBox(height: 16,),
            Text(
              "Important Medical Disclaimer",
              style: Theme.of(context).textTheme.headlineMedium?. copyWith(
                color: AppConstants.warningColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16,),
            const Text(
              "DermAssist is a screening tool powered by AI and is NOT a substitute for professional medical advice, diagnosis, or treatment.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12,),
            const Text(
              "The differential diagnoses provided are probabilistic and based on the image and symptoms you provided. Always seek the advice of a qualified dermatological or physician with any questions you may have regarding a medical consiions.",
              style: TextStyle(
                fontSize: 14,),
                textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32,),
            ElevatedButton(
              onPressed: (){
                setState(() => _hasAcceptedDisclaimer = true);
                Navigator.pop(context);
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text("I Understand & Agree"),
              ),
              const SizedBox(height: 16,),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    Widget body = _buildResultsContent();
    if(!_hasAcceptedDisclaimer){
      body = Stack(
        children: [
          opacityContent(body),
          Container(color: Colors.black,
           ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Results"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: (){
           // Provider.of<ConsultationProvider>(context, listen: false).resetCurrentConsultation();
            Navigator.pushNamedAndRemoveUntil(context, AppRouter.main, (route) => false);
          },
       ),
       actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _hasAcceptedDisclaimer ? () {

          } : null,
       ),
      ],
      ),
      body: body,
      bottomNavigationBar: _hasAcceptedDisclaimer? _buildBottomActions() : null,

    );
  }
  Widget opacityContent(Widget content){
    return Opacity(
      opacity: 0.3,
      child: IgnorePointer(child: content),
      );
  }
  Widget _buildResultsContent(){
    String risk = (_result['risk_level'] ?? '').toString().toLowerCase();
    Color riskColor;

    if (risk.contains("high")) {
      riskColor = AppConstants.errorColor;
    } else if (risk.contains("medium")) {
      riskColor = AppConstants.warningColor;
    } else {
      riskColor = AppConstants.successColor;
    }
   

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Risk Level Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: riskColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  //_result['risk_level'] == AppConstants.riskLow ? Icons.check_circle : Icons.warning_rounded,
                  risk.contains("low") ? Icons.check_circle_outline : Icons.error_outline,
                  color: riskColor,
                  size: 32,
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assessed Risk Level",
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          _result['risk_level'] ?? "Unknown".toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 26,
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24,),
          // Original Image Thumbnail
          /*if(imageFile != null)...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: Image.file(
                imageFile,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24,),
          ],*/
          // Top Differential Diagnoses
          Text(
            "Top Differential Diagnoses",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12,),

         ...((_result['possible_diagnoses'] ?? []) as List)
    .asMap()
    .entries
    .map((entry) {
  final index = entry.key;

  if (entry.value is! Map) return const SizedBox(); // ✅ safety

  final Map<String, dynamic> diag =
      Map<String, dynamic>.from(entry.value);

  return _buildDiagnosisCard(diag, index == 0);
}).toList(),

           const SizedBox(height: 24,),

           // Overall AI Reasoning
           Text(
            "Clinical AI Reasoning",
            style: Theme.of(context).textTheme.titleLarge,
           ),
           const SizedBox(height: 12,),
           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: Text(
                      _result['ai_reasoning'] ?? 'No reasoning provided',
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
              ],
            ),
           ),
           const SizedBox(height: 16,),
           ],
      ),
    );
  }
  Widget _buildDiagnosisCard(Map<String, dynamic> diagnosis, bool isTopResult) {

  // ✅ SAFE condition_name handling (MAIN FIX)
  String conditionName;
  if (diagnosis['condition_name'] is String) {
    conditionName = diagnosis['condition_name'];
  } else if (diagnosis['condition_name'] is Map) {
    conditionName =
        diagnosis['condition_name']['condition_name']?.toString() ?? "Unknown";
  } else {
    conditionName = "Unknown";
  }

  // ✅ SAFE confidence handling
  int confidence = 0;
  if (diagnosis['confidence_percentage'] is int) {
    confidence = diagnosis['confidence_percentage'];
  } else if (diagnosis['confidence_percentage'] is String) {
    confidence = int.tryParse(diagnosis['confidence_percentage']) ?? 0;
  }

  // ✅ SAFE reasoning
  String reasoning = (diagnosis['clinical_reasoning'] ?? '').toString();

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: isTopResult ? 4 : 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      side: BorderSide(
        color: isTopResult ? AppConstants.primaryColor : Colors.grey.shade200,
        width: isTopResult ? 2 : 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conditionName, // ✅ FIXED HERE
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isTopResult ? FontWeight.bold : FontWeight.w600,
                        color: isTopResult ? AppConstants.primaryColor : null,
                      ),
                    ),
                    Text(
                      "Risk Level: ${(_result['risk_level'] ?? 'Low').toString()}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$confidence%", // ✅ FIXED HERE
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence / 100, // ✅ FIXED HERE
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTopResult
                    ? AppConstants.primaryColor
                    : Colors.grey.shade400,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            reasoning, // ✅ FIXED HERE
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomActions(){
    return Container(
      padding: const EdgeInsets.all(AppConstants.borderRadius),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black,
        offset: const Offset(0, -5),
        blurRadius: 10
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: (){
            Navigator.pushNamed(context, AppRouter.providerSearch);
          },
          icon: const Icon(Icons.location_on_outlined), 
          label: const Text("Find Healthcare Providers"),
          ),
          const SizedBox(height: 12,),
          OutlinedButton.icon(
            onPressed: (){
              Navigator.pushNamed(context,
               AppRouter.pdfReport, 
               arguments: {
                'consultationId': 'consultationId',
                'result': _result,
               },
               );
            }, 
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text("Generate PDF Report"),
            ),
      ],
    ),
    );
  }
}