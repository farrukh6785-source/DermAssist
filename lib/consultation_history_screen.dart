import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/router.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  State<ConsultationHistoryScreen> createState() => ConsultationHistoryScreenState();
}

class ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedRiskFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation History"),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consultations')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Filtering Logic
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final result = data['result'] as Map<String, dynamic>? ?? {};
                  final symptoms = data['symptoms'] as Map<String, dynamic>? ?? {};
                  
                  final risk = (result['riskLevel'] ?? result['risk_level'] ?? 'LOW')
    .toString()
    .toUpperCase()
    .trim();

                  final description = (symptoms['description'] ?? '').toString().toLowerCase();
                  final query = _searchController.text.toLowerCase();

                  bool matchesRisk = _selectedRiskFilter == 'ALL' || risk == _selectedRiskFilter;
                  bool matchesSearch = query.isEmpty || description.contains(query);

                  return matchesRisk && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No history found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _buildConsultationCard(filteredDocs[index].id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search symptoms...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Row(
            children: [
              const Text("Risk: ", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedRiskFilter,
                items: ['ALL', 'HIGH', 'MEDIUM', 'LOW']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRiskFilter = val!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(String id, Map<String, dynamic> data) {
  final createdAt = data['createdAt'] as Timestamp?;

  final dateStr = createdAt != null
      ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}"
      : "Recent";

  final result = Map<String, dynamic>.from(data['result'] ?? {});

  /// ✅ FIX 1: Safe diagnoses extraction
  final diagnoses = (result['possible_diagnoses'] is List)
    ? result['possible_diagnoses'] as List
    : [];


  /// ✅ FIX 2: Get TOP condition safely
  String mainCondition = "Unknown";

  if (diagnoses.isNotEmpty && diagnoses[0] is Map) {
    final first = diagnoses[0];

    mainCondition =
        first['condition_name'] ?? // AI model format
        first['condition'] ??      // fallback
        first['name'] ??           // fallback
        "Analysis";
  }

  /// ✅ FIX 3: Risk level fix (snake_case + camelCase both supported)
  final riskLevel = (result['risk_level'] ??
          result['riskLevel'] ??
          'LOW')
      .toString()
      .toUpperCase();

  final riskColor = riskLevel == 'HIGH'
      ? Colors.red
      : (riskLevel == 'MEDIUM'
          ? Colors.orange
          : Colors.green);

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.consultationDetails,
        arguments: {'consultationId': id},
      ),

      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: data['imageUrl'] != null
            ? Image.network(
                data['imageUrl'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                cacheWidth: 150,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              )
            : const Icon(Icons.image, size: 60),
      ),

      title: Text(
        mainCondition,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      subtitle: Text(dateStr),

      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: riskColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          riskLevel,
          style: TextStyle(
            color: riskColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}