import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/models/consultation_model.dart';
import 'package:dermassist_fyp/providers/consultation_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomInputScreen extends StatefulWidget{
  final String ? imageUrl;
  //final String? imagePath;
  const SymptomInputScreen({super.key, required this.imageUrl});
  
  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen>{
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedDuration = "Days";
  final List<String> _durationOptions = ["Hours", "Days", "Weeks", "Month", "Years"];

  // Characteristics
  bool _isItchy = false;
  bool _isPainful = false;
  bool _isBleeding = false;
  bool _isSpreading = false;
  bool _hasDischarge = false;
  bool _isFlaky = false;

  @override
  void dispose(){
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForAnalysis() async{
    if(_formKey.currentState!.validate()){
      // Collect Characteristcs
      List<String> characteristics = [];
      if(_isItchy) characteristics.add('Itching');
      if(_isPainful) characteristics.add('Pain');
      if(_isBleeding) characteristics.add('Bleeding');
      if(_isSpreading) characteristics.add('Spreading');
      if(_hasDischarge) characteristics.add('Discharge/Pus');
      if(_isFlaky) characteristics.add('Flaky/Scaling');

      // Create Symptom Data
      final symptomData = SymptomData(
        bodyLocation: _locationController.text.trim(),
        description: _descController.text.trim(),
        duration: _selectedDuration,
        characteristics: characteristics,
      );

      // Save to Provider
      final provider =Provider.of<ConsultationProvider>(context, listen: false);
      // Save to firebase firestore
      try{
        // Firebase
        final consultationId = provider.consultationId;
        if(consultationId == null){
          throw Exception("Consultation ID not found");
        }
        await FirebaseFirestore.instance
        .collection('consultations')
        .doc(provider.consultationId)
        .update({'symptoms': symptomData.toJson(),
        'status': 'symptoms_added',
        });
        provider.setSymptoms(symptomData);



//  Navigate to next screen with data
        Navigator.pushNamed(
        context, 
        AppRouter.analysisLoading,
        arguments: {
          'consultationId': provider.consultationId,
          'imageUrl': widget.imageUrl,
          'symptomData': symptomData.toJson(),
        },
        );
      } catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing image: $e")),
          );
      }

      
    }
  }
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Describe Symptoms"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(context),
                const SizedBox(height: 32,),

                // Image Thumbnail 
                Row(
                  children: [
                    if(widget.imageUrl !=null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                       
                      child:Image.network(
                        widget.imageUrl! ,
                        
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                    else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.broken_image),
                    ),
                    const SizedBox(width: 16,),
                    Expanded(
                      child: Text(
                        "Provide details about this lesion to help the AI perform an accurate analysis.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32,),
               // Body Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Body Location (e.g., Left forearm, face, neck, legs, hands)",
                    prefixIcon: Icon(Icons.accessibility_new_rounded),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Please specify where this lession is located";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20,),
                // Duration Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDuration,
                  decoration: const InputDecoration(
                    labelText: "Duration (How long have you had it?)",
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  items: _durationOptions.map((String value){
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                      );
                  }).toList(), onChanged: (newValue){
                    setState(() {
                      _selectedDuration = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                
                // Description Text Area
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  maxLength: AppConstants.symptomDescMaxLength,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    hintText: "Describe how it looks, feels, or any changes you noticed....",
                    alignLabelWithHint: true,
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Please provide a brief description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24,),

                // Characteristics Checkboxes
                Text(
                  "Characteristics & Symptoms",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8,),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Colors.grey.shade200),

                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text("Itching (Pruritus)"),
                        value: _isItchy,
                        onChanged: (val)=>setState(() => _isItchy = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                       CheckboxListTile(
                        title: const Text("Pain or Tenderness"),
                        value: _isPainful,
                        onChanged: (val)=>setState(() => _isPainful = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                      CheckboxListTile(
                        title: const Text("Bleeding"),
                        value: _isBleeding,
                        onChanged: (val)=>setState(() => _isBleeding = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                      CheckboxListTile(
                        title: const Text("Rapid Spreading/Growing"),
                        value: _isSpreading,
                        onChanged: (val)=>setState(() => _isSpreading = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                      CheckboxListTile(
                        title: const Text("Discharge, Oozing, or Pus"),
                        value: _hasDischarge,
                        onChanged: (val)=>setState(() => _hasDischarge = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                        title: const Text("Flaky, Scaly or Crusting"),
                        value: _isFlaky,
                        onChanged: (val)=>setState(() => _isFlaky = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32,),
                // Submit Button
                ElevatedButton.icon(
                  onPressed: _submitForAnalysis, 
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text("Submit for AI Analysis"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),

                  ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context){
    return Row(
      children: [
        _buildStepIndicator(context, '1', true),
        _buildStepLine(context, true),
        _buildStepIndicator(context, '2', true),
        _buildStepLine(context, true),
        _buildStepIndicator(context, '3', true),
      ],
    );
  }
  Widget _buildStepIndicator(BuildContext context, String text, bool isActive){
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Widget _buildStepLine(BuildContext context, bool isActive){
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
      ),
    );
  }
}