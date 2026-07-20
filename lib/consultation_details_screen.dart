import 'package:flutter/material.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dermassist_fyp/constants.dart';

class ConsultationDetailsScreen extends StatefulWidget {
  const ConsultationDetailsScreen({super.key});

  @override
  State<ConsultationDetailsScreen> createState() =>
      ConsultationDetailsScreenState();
}

class ConsultationDetailsScreenState
    extends State<ConsultationDetailsScreen> {
  String? consultationId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArgs();
    });
  }

  void _loadArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      consultationId = args;
    } else if (args is Map) {
      consultationId = args['id'] ?? args['consultationId'];
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildConsultationStream() {
    if (consultationId == null) {
      return const Center(child: Text("No consultation ID provided"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .doc(consultationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No consultation data found"));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final result = data['result'] ?? {};
        final symptoms = data['symptoms'] ?? {};

        final diagnoses = (result['possible_diagnoses'] ?? []) as List;

        final characteristics = symptoms['characteristics'] ?? [];
         final riskLevel =
      result['riskLevel'] ??
      result['risk_level'] ??
       "N/A";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID
                  Text(
                    "Consultation ID: $consultationId",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.textPrimaryLight),
                  ),
                  const Divider(),

                  // Image
                  if (data['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['imageUrl'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Risk Level
                 

      Text(
      "Risk Level: $riskLevel",
     style: TextStyle(
     fontWeight: FontWeight.bold,
     color: riskLevel == "HIGH"
        ? Colors.red
        : (riskLevel == "MEDIUM"
            ? Colors.orange
            : Colors.green),
  ),
),


                  const SizedBox(height: 10),

                  // Symptoms
                  const Text("Symptoms",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppConstants.textPrimaryLight)),
                  const SizedBox(height: 6),

                  Text("Description: ${symptoms['description'] ?? 'N/A'}"),
                  Text("Duration: ${symptoms['duration'] ?? 'N/A'}"),
                  Text("Location: ${symptoms['bodyLocation'] ?? 'N/A'}"),
                  Text(
                      "Characteristics: ${characteristics.isNotEmpty ? characteristics.join(', ') : 'N/A'}"),

                  const SizedBox(height: 16),

                  // AI Diagnoses
                  const Text("AI Diagnoses",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryLight)),
                  const SizedBox(height: 6),

                  if (diagnoses.isNotEmpty)
  ...diagnoses.map<Widget>((d) {
    final name = d['condition_name'] ?? 'Unknown';
    final confidence = d['confidence_percentage'] ?? 0;

    return Text("• $name ($confidence%)");
  }).toList()
else
  const Text("No AI diagnoses available"),



                  const SizedBox(height: 16),

                  // Clinical Reasoning
                  if (result['clinicalReasoning'] != null) ...[
                    const Text("Clinical Reasoning",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(result['clinicalReasoning']),
                    const SizedBox(height: 16),
                  ],

                  
                  if (result['recommendedActions'] != null) ...[
                    const Text("Recommendations",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...List.from(result['recommendedActions'])
                        .map((e) => Text("• $e"))
                        .toList(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteConsultation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Consultation"),
        content:
            const Text("Are you sure you want to delete this consultation?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true || consultationId == null) return;

    await FirebaseFirestore.instance
        .collection('consultations')
        .doc(consultationId)
        .delete();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation Details"),
        actions: [
          IconButton(
            onPressed: _deleteConsultation,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),

      body: _buildConsultationStream(),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: consultationId == null
                ? null
                : () {
                    Navigator.pushNamed(context, AppRouter.pdfReport,
                        arguments: {'consultationId': consultationId});
                  },
            child: const Text("Download Report"),
          ),
        ),
      ),
    );
  }
}
