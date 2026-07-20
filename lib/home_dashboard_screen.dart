import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/router.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'package:dermassist_fyp/providers/consultation_provider.dart';
import 'package:intl/intl.dart';

class HomeDashboardScreen extends StatefulWidget{
  const HomeDashboardScreen({super.key});
  @override
  State<HomeDashboardScreen> createState()=> _HomeDashboardScreenState();

}
class _HomeDashboardScreenState extends State<HomeDashboardScreen>{
  @override
  void initState(){
    super.initState();
    //Load history when dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!mounted) return;
      Provider.of<ConsultationProvider>(context, listen: false).loadHistory();
    });
  }
  @override
  Widget build(BuildContext context){
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final firstName = user?.fullName.split(' ').first ?? 'user';
    final consultationProvider = context.watch<ConsultationProvider>();
    final recentConsultations = consultationProvider.consultations.take(3).toList();
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
         onRefresh: () => consultationProvider.loadHistory(),
          child: CustomScrollView(
            slivers: [
              // Custom Animated App Bar
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Text(
                    "Hello, $firstName 👋 ",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 20,
                        //backgroundColor: AppConstants.primaryColor,
                        backgroundImage: user?.profilePhotoUrl !=null
                        ? NetworkImage(user!.profilePhotoUrl!)
                        : null,
                        child: user?.profilePhotoUrl == null
                        ? Icon(Icons.person, )
                        : null,
                      ),
                      ),
                  ),
                ),
              ),
              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:[
                               AppConstants.primaryColor,
                            AppConstants.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor,
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                        ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Check your skin health today",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Text(
                                  "AI-powered instant screening",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16,),
                                ElevatedButton(
                                  onPressed:(){
                                    Navigator.pushNamed(context, AppRouter.newConsultation);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppConstants.primaryColor,
                                    minimumSize: const Size(0,40),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                   child: const Text("New Consultaiton"),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.document_scanner_outlined,
                            size: 80,
                            color: Colors.white70,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                     Text(
            "Quick Actions",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
        Row(
      children: [
        Expanded(
       child: _buildQuickActionCard(
        context,
        icon: Icons.local_hospital_rounded,
         title: "Find Providers",
         subtitle: "Nearby clinics & pharmacies",
          onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.providerSearch,
          );
          },
       ),
      ),
   ],
    ),


                    const SizedBox(height: 12,),
                    // Recent Consultation header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Consultations",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if(recentConsultations.isEmpty)
                          TextButton(
                            onPressed: (){

                            }, 
                            child: const Text("See All"),
                            ),
                        
                      ],
                    ),
                    const SizedBox(height: 16,),
                    // Recent Consultations List
                    if(consultationProvider.isLoading)
                    const Center (
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                        ),
                      )
                      else if(recentConsultations.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300,),
                              const SizedBox(height: 16,),
                              Text("No consultation yet",
                              style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                      else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentConsultations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12,),
                        itemBuilder: (context, index){
                          final item = recentConsultations[index];
                          return _buildConsultationCard(context, item);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
       ),
    ),
  );
}
Widget _buildQuickActionCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  AppConstants.primaryColor.withOpacity(0.1),
              child: Icon(
                icon,
                color: AppConstants.primaryColor,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildConsultationCard(BuildContext context, dynamic consultation){
//final riskLevel = consultation.result?.riskLevel ?? "pending";
//final diagnoses = consultation.result?.differentialDiagnoses;

 final result = consultation.result;

// safe values
final riskLevel = (result?.riskLevel ?? "PENDING").toString().toUpperCase();
final diagnoses = result?.differentialDiagnoses ?? [];

// ⭐ SINGLE SOURCE OF TRUTH
final bool isCompleted =
    riskLevel != "PENDING" && riskLevel.isNotEmpty;

final title = isCompleted
    ? (diagnoses.isNotEmpty
        ? (diagnoses.first['condition_name'] ??
           diagnoses.first['condition'] ??
           "Analysis")
        : "Analysis Complete")
    : "Pending Analysis";

final statusText = isCompleted ? "Completed" : "Pending";



   Color badgeColor;

if (!isCompleted) {
  badgeColor = Colors.grey;
} else if (riskLevel == "HIGH") {
  badgeColor = Colors.red;
} else if (riskLevel == "MEDIUM") {
  badgeColor = Colors.orange;
} else {
  badgeColor = Colors.green;
}



 /* Color badgeColor = AppConstants.successColor;
  if(riskLevel == AppConstants.riskHigh){
    badgeColor = AppConstants.errorColor;
  } else if(riskLevel == AppConstants.riskMedium){
    badgeColor = AppConstants.warningColor;
  }*/
  return Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: (){
        Navigator.pushNamed(
          context, 
          AppRouter.consultationDetails,
          arguments: {'consultationId': consultation.id},
          );
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (consultation.imageUrl ?? "").isNotEmpty
              ? Image.network(
                consultation.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>_buildPlaceholderThumbnail(),
                )
                : _buildPlaceholderThumbnail(),
            ),
            const SizedBox(width: 16),
            // Details
            
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    (diagnoses.isNotEmpty && diagnoses.first is Map)
                        ? (diagnoses.first['condition_name'] ??
                           diagnoses.first['condition'] ??
                           "Analysis")
                        : "Pending Analysis",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4,),
                  Text(
                    DateFormat('MMM dd, yyyy . hh:mm a').format(consultation.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4,),
                    Text(
                    isCompleted ? "Status: Completed" : "Status: Pending",
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Risk Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor),
              ),
              child: Text(
                riskLevel,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        ),
    ),
  );
}

Widget _buildPlaceholderThumbnail(){
  return Container(
    width: 60,
    height: 60,
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_outlined, color: Colors.grey),
  );
}
}