import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFReportScreen extends StatefulWidget{
  const PDFReportScreen ({super.key});

  @override
  State<PDFReportScreen> createState () => _PDFReportScreenState();
}

class _PDFReportScreenState extends State <PDFReportScreen>{

  String ? _consultationId;
  String ? _pdfFilePath;
  bool _isDownloading = false;
  bool _isSharing = false;

  final Map<String, dynamic> _mockConsultationData = {
    'consultationId' : "",
    'patientName' : "N/A",
    'patientAge' : 0,
    'patientGender' : "N/A",
    'consultationDate' : DateTime.now(),
    'symptomDescription' : "",
    'structuredSymptoms' : {
      'duration' : '',
      'bodyLocation' : '',
      'characteristics' : [],
    },
    'riskLevel' : "MEDIUM",
    'aiResponse' : {
      'differentialDiagnoses' : [],
      'clinicalReasoning' : '',
      'recommendedActions' : [],
    },
  };

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      if(args != null){
        _consultationId = args['consultationId'];

        final result = args['result'];

        // ✅ AI RESULT
        if(result != null){
          // ================= RISK LEVEL FIX =================

_mockConsultationData['riskLevel'] =
    result['risk_level'] ??
    result['riskLevel'] ??
    _mockConsultationData['riskLevel'] ??
    'MEDIUM';

// ================= AI RESPONSE FIX =================

// Inside initState -> if(result != null)
final possibleDiagnoses = List<Map<String, dynamic>>.from(result['possible_diagnoses'] ?? result['differentialDiagnoses'] ?? []);

_mockConsultationData['aiResponse'] = {
  'differentialDiagnoses': possibleDiagnoses.map((d) {
    return {
      'condition': d['condition_name'] ?? d['condition'] ?? 'Unknown',
      'confidence': d['confidence_percentage'] ?? d['confidence'] ?? 0,
      'reasoning': d['clinical_reasoning'] ?? d['reasoning'] ?? '',
    };
  }).toList(),
  'clinicalReasoning': result['ai_reasoning'] ?? result['aiReasoning'] ?? result['clinicalReasoning'] ?? "",
  'recommendedActions': List<String>.from(result['recommended_actions'] ?? result['recommendedActions'] ?? []),
};
        }

        // ✅ LOAD FIRESTORE DATA AFTER ID SET
        _loadConsultationData();
      }
    });
  }

  Future<void> _loadConsultationData() async {
  try {
    if (_consultationId == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('consultations')
        .doc(_consultationId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    final symptoms = Map<String, dynamic>.from(data['symptoms'] ?? {});
    final result = Map<String, dynamic>.from(data['result'] ?? {});

    final firebaseUser = FirebaseAuth.instance.currentUser;

    Map<String, dynamic>? userData;

    // 🔥 FETCH USER DATA FROM FIRESTORE (CRITICAL FIX)
    if (firebaseUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        userData = userDoc.data();
      }
    }

    setState(() {

      // ✅ REPORT ID FIX
      _mockConsultationData['consultationId'] = _consultationId ?? "";

      // ✅ DATE
      _mockConsultationData['consultationDate'] =
          (data['createdAt'] != null)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now();

      // ✅ USER INFO FIX (MAIN BUG FIX)
      _mockConsultationData['patientName'] =
          userData?['fullName'] ??
          data['patientName'] ??
          firebaseUser?.displayName ??
          "N/A";

      _mockConsultationData['patientAge'] =
          userData?['age'] ??
          data['patientAge'] ??
          0;

      _mockConsultationData['patientGender'] =
          userData?['gender'] ??
          data['patientGender'] ??
          "N/A";

      // ✅ SYMPTOMS
      _mockConsultationData['symptomDescription'] =
          symptoms['description'] ?? 'No description available';

      _mockConsultationData['structuredSymptoms'] = {
        'duration': symptoms['duration'] ?? 'N/A',
        'bodyLocation': symptoms['bodyLocation'] ?? 'N/A',
        'characteristics': List<String>.from(symptoms['characteristics'] ?? []),
      };

      // ✅ RISK
      _mockConsultationData['riskLevel'] =
          result['riskLevel'] 
          ?? result['risk_level']
          ??'MEDIUM';
          if (result.isNotEmpty) {
    _mockConsultationData['aiResponse'] = {
      'differentialDiagnoses': (result['differentialDiagnoses'] ?? result['possible_diagnoses'] ?? []),
      'clinicalReasoning': result['clinicalReasoning'] ?? result['ai_reasoning'] ?? "",
      'recommendedActions': result['recommendedActions'] ?? result['recommended_actions'] ?? [],
    };
  }
    });

  } catch (e) {
    print("❌ Consultation fetch error: $e");
  }
}
Future<pw.Document> _generatePDF() async {
  final pdf = pw.Document();

  final patientName = _mockConsultationData['patientName'] as String;
  final patientAge = _mockConsultationData['patientAge'] as int;
  final patientGender = _mockConsultationData['patientGender'] as String;
  final consultationDate = _mockConsultationData['consultationDate'] as DateTime;
  final consultationId = _mockConsultationData['consultationId'] as String;
  final symptomDescription = _mockConsultationData['symptomDescription'] as String;
  final structuredSymptoms = _mockConsultationData['structuredSymptoms'] as Map<String, dynamic>;
  final riskLevel = _mockConsultationData['riskLevel'] as String;

  final aiResponse = _mockConsultationData['aiResponse'] as Map<String, dynamic>;

  final diagnosesRaw = (aiResponse['differentialDiagnoses'] ?? []) as List<dynamic>;
  final clinicalReasoning = aiResponse['clinicalReasoning']?.toString() ?? "No reasoning provided.";
  final recommendedActions = (aiResponse['recommendedActions'] ?? []) as List<dynamic>;

  final formattedDate = DateFormat('dd MMM yyyy').format(consultationDate);
  final formattedTime = DateFormat('hh:mm a').format(consultationDate);

  // ✅ SAFE PARSING (IMPORTANT FIX)
  final diagnoses = diagnosesRaw.map((d) {
    if (d is Map) {
      return {
        'condition': d['condition_name'] ?? d['condition'] ?? d['label'] ?? 'Unknown',
        'confidence': d['confidence_percentage'] ?? d['confidence'] ?? d['score'] ?? 0,
      };
    }
    return {
      'condition': d.toString(),
      'confidence': 0,
    };
  }).toList();
  

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),

      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          "Page ${context.pageNumber} / ${context.pagesCount}",
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),

      build: (context) => [

        // ================= HEADER =================
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          color: PdfColors.teal50,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("DermAssist Medical Report",
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal)),
              pw.SizedBox(height: 5),
              pw.Text("Report ID: $consultationId"),
              pw.Text("Date: $formattedDate | $formattedTime"),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // ================= PATIENT TABLE =================
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            _row("Patient Name", patientName),
            _row("Age", "$patientAge"),
            _row("Gender", patientGender),
            _row("Risk Level", riskLevel),
          ],
        ),

        pw.SizedBox(height: 20),

        // ================= SYMPTOMS =================
        _sectionTitle("Symptoms"),

        pw.Text(symptomDescription),
        pw.SizedBox(height: 8),

        pw.Bullet(text: "Duration: ${structuredSymptoms['duration']}"),
        pw.Bullet(text: "Location: ${structuredSymptoms['bodyLocation']}"),
        pw.Bullet(text: "Characteristics: ${(structuredSymptoms['characteristics'] as List).join(', ')}"),

        pw.SizedBox(height: 20),

        // ================= DIAGNOSES TABLE (FIXED) =================
        _sectionTitle("AI Diagnoses"),

        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell("Condition", bold: true),
                _cell("Confidence", bold: true),
              ],
            ),

            ...diagnoses.map((d) {
              return pw.TableRow(
                children: [
                  _cell(d['condition']),
                  _cell("${d['confidence']}%"),
                ],
              );
            }).toList(),
          ],
        ),

        pw.SizedBox(height: 20),

        // ================= REASONING =================
        _sectionTitle("Clinical Reasoning"),
        pw.Text(clinicalReasoning),

        pw.SizedBox(height: 20),

        // ================= RECOMMENDATIONS =================
        _sectionTitle("Recommendations"),
        if (recommendedActions.isEmpty)
  pw.Text("No specific recommendations provided at this time.", 
          style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
else
  pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: recommendedActions.map((r) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Bullet(
          text: r.toString(), 
          style: const pw.TextStyle(fontSize: 10)
        ),
      );
    }).toList(),
  ),

        //...recommendedActions.map((r) => pw.Bullet(text: r.toString())),

        pw.SizedBox(height: 20),

        // ================= DISCLAIMER =================
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          color: PdfColors.red50,
          child: pw.Text(
            "This is AI-generated report. Consult doctor before treatment.",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );

  return pdf;
}
pw.TableRow _row(String a, String b) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(a, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(b),
      ),
    ],
  );
}

pw.Widget _cell(String text, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

pw.Widget _sectionTitle(String title) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(6),
    color: PdfColors.teal50,
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    ),
  );
}

  /*Future<pw.Document> _generatePDF () async {
    final pdf = pw.Document();

    final patientName = _mockConsultationData['patientName'] as String;
    final patientAge = _mockConsultationData['patientAge'] as int;
    final patientGender = _mockConsultationData['patientGender'] as String;
    final consultationDate = _mockConsultationData['consultationDate'] as DateTime;
    final consultationId  = _mockConsultationData['consultationId'] as String;
    final symptomDescription = _mockConsultationData['symptomDescription'] as String;
    final structuredSymptoms = _mockConsultationData['structuredSymptoms'] as Map<String, dynamic>;
    final riskLevel = _mockConsultationData['riskLevel'] as String;

    final aiResponse = _mockConsultationData['aiResponse'] as Map<String, dynamic>;

    final diagnoses = (aiResponse['differentialDiagnoses'] ?? []) as List<dynamic>;
    final clinicalReasoning = aiResponse['clinicalReasoning'] as String;
    final recommendedActions = (aiResponse['recommendedActions'] ?? []) as List<dynamic>;

    final formattedDate = DateFormat('MM dd, yyyy').format(consultationDate);
    final formattedTime = DateFormat('hh:mm a').format(consultationDate);

    pdf.addPage(
      pw.MultiPage(
        pageFormat : PdfPageFormat.a4,
        margin : pw.EdgeInsets.all(40),

        build: (context) => [

  pw.Text(
    "DERMASSIST CONSULTATION REPORT",
    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
  ),

  pw.SizedBox(height: 20),

  // ================= PATIENT INFO =================
  pw.Text("PATIENT INFORMATION",
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

  pw.SizedBox(height: 10),

  pw.Table.fromTextArray(
    headers: ['Field', 'Value'],
    data: [
      ['Name', patientName],
      ['Age', patientAge.toString()],
      ['Gender', patientGender],
      ['Consultation Date', '$formattedDate $formattedTime'],
      ['Consultation ID', consultationId],
    ],
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    cellAlignment: pw.Alignment.centerLeft,
  ),

  pw.SizedBox(height: 20),

  // ================= SYMPTOMS =================
  pw.Text("SYMPTOMS",
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

  pw.SizedBox(height: 10),

  pw.Table.fromTextArray(
    headers: ['Field', 'Detail'],
    data: [
      ['Description', symptomDescription],
      ['Duration', structuredSymptoms['duration'].toString()],
      ['Body Location', structuredSymptoms['bodyLocation'].toString()],
      [
        'Characteristics',
        (structuredSymptoms['characteristics'] as List).isEmpty
            ? "N/A"
            : (structuredSymptoms['characteristics'] as List).join(", ")
      ],
    ],
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    cellAlignment: pw.Alignment.centerLeft,
  ),

  pw.SizedBox(height: 20),

  // ================= RISK LEVEL =================
  pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(),
    ),
    child: pw.Text(
      "RISK LEVEL: $riskLevel",
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    ),
  ),

  pw.SizedBox(height: 20),

  // ================= DIAGNOSES =================
  pw.Text("DIAGNOSES",
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

  pw.SizedBox(height: 10),

  pw.Table.fromTextArray(
    headers: ['#', 'Condition', 'Confidence'],
    data: diagnoses.asMap().entries.map((entry) {
      final d = entry.value;
      return [
        (entry.key + 1).toString(),
        d['condition'] ?? 'N/A',
        '${d['confidence'] ?? 0}%'
      ];
    }).toList(),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    cellAlignment: pw.Alignment.centerLeft,
  ),

  pw.SizedBox(height: 20),

  // ================= CLINICAL REASONING =================
  pw.Text("CLINICAL REASONING",
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

  pw.SizedBox(height: 8),

  pw.Text(clinicalReasoning.isEmpty
      ? "No reasoning available"
      : clinicalReasoning),

  pw.SizedBox(height: 20),

  // ================= RECOMMENDATIONS =================
  pw.Text("RECOMMENDATIONS",
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

  pw.SizedBox(height: 10),

  pw.Column(
    children: recommendedActions.map((a) {
      return pw.Bullet(text: a.toString());
    }).toList(),
  ),
],

      ),
    );

    return pdf;
  }*/

  //import 'dart:io';
//import 'package:permission_handler/permission_handler.dart';

/*Future<void> _downloadPDF() async {
  try {
    setState(() => _isDownloading = true);

    // ✅ Request permission
    var status = await Permission.storage.request();

    if (!status.isGranted) {
      throw Exception("Storage permission denied");
    }

    final pdf = await _generatePDF();
    final bytes = await pdf.save();

    // ✅ Public Downloads folder
    final dir = Directory('/storage/emulated/0/Download');

    final file = File(
      '${dir.path}/DermAssist_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(bytes);

    print("✅ PDF SAVED AT: ${file.path}");

    setState(() {
      _pdfFilePath = file.path;
      _isDownloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved in Downloads folder")),
    );

  } catch (e) {
    print("❌ ERROR: $e");

    setState(() => _isDownloading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}*/
 Future<void> _downloadPDF() async {
    setState(() => _isDownloading = true);
    try{
      final pdf = await _generatePDF();
      Directory ? directory;
      if(Platform.isAndroid){
        directory = Directory('/storage/emulated/0/Download');
        // If Downloads folder dosn't exist, create it
        if(!await directory.exists()){
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      // Create file path with unique filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'DermAssist_Report_${_consultationId}_$timestamp.pdf';
      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      setState(() {
        _pdfFilePath = filePath;
        _isDownloading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report downloaded successfully!\n $filePath"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK', 
          textColor: Colors.white,
          onPressed: (){}
          ),
        ),
        );
    } catch (e){
      setState(() => _isDownloading = false);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading PDF: $e"),
          backgroundColor: Colors.red,
          ),
        );
    }
  }



  Future<void> _sharePDF() async {
    setState(() => _isSharing = true);

    final pdf = await _generatePDF();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/report.pdf');

    await file.writeAsBytes(await pdf.save());

    setState(() => _isSharing = false);

    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
   Widget build(BuildContext context){ 
    return Scaffold(
       appBar: AppBar( 
        title: Text("PDF Report"), 
        backgroundColor: AppConstants.primaryColor, ), 
        body: SingleChildScrollView( 
          child: Padding( 
            padding: EdgeInsets.all(24), 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [ 
                //PDF icon 
                Container( 
                  width: 120, 
                  height: 120, 
                  decoration: BoxDecoration( 
                    color: Colors.white, 
                    shape: BoxShape.circle, 
                    ),
                     child: Icon( Icons.picture_as_pdf, size: 90, color: Colors.red, ),
                      ), 
                      SizedBox(height: 30,), 
                      Text("Medical Report", 
                      style: TextStyle( 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: AppConstants.textPrimaryLight
                        ), 
                        textAlign: TextAlign.center,
                         ), SizedBox(height: 12,), 
                         Text( "Consultation ID: ${_consultationId ?? "N/A"}", 
                         style: TextStyle( 
                          fontSize: 14, 
                          color: Colors.grey.shade600,
                          ), 
                          textAlign: TextAlign.center, 
                          ), SizedBox(height: 8,), 
                          Text( "Generated: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}", 
                          style: TextStyle( 
                            fontSize: 14, color: Colors.grey.shade600, 
                            ), textAlign: TextAlign.center, 
                            ), SizedBox(height: 40,), 
                            // Report Preview info 
                            Container( 
                              padding: EdgeInsets.all(16), 
                              decoration: BoxDecoration( 
                                color: Colors.grey.shade100, 
                                borderRadius: BorderRadius.circular(8), 
                                border: Border.all(color: Colors.grey.shade300), 
                                ), 
                                child: Column( 
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [ 
                                    Text("Report Includes: ", 
                                    style: TextStyle( 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16, ), 
                                      ), SizedBox(height: 12,), 
                                      _buildReportItem('✓ Patient information'), 
                                      _buildReportItem('✓ Detailed symptom description'), 
                                      _buildReportItem('✓ AI assessment with risk level'), 
                                      _buildReportItem('✓ Differential diagnoses with confidence'), 
                                      _buildReportItem('✓ Clinical reasoning'), 
                                      _buildReportItem('✓ Professional recommendations'), 
                                      _buildReportItem('✓ Medical disclaimer'), 
                                      ], 
                                    ), 
                                  ),
                                      SizedBox(height: 40,), 
                                      
                                      // Download button 
                                      
                                      Row( 
                                        children: [
                                          Expanded( 
                                            child: OutlinedButton.icon( 
                                              onPressed: _isSharing ? null: _sharePDF, 
                                              icon: _isSharing ? 
                                              SizedBox( 
                                                width: 20, 
                                                height: 20, 
                                                child: CircularProgressIndicator( 
                                                  strokeWidth: 2, ), 
                                                  ) 
                                                  : Icon(Icons.share), 
                                                  label: Text("Share PDF"), 
                                                  style: OutlinedButton.styleFrom( 
                                                    padding: EdgeInsets.symmetric(vertical: 16), 
                                                    side: BorderSide(
                                                      color: AppConstants.secondaryColor, width: 2), 
                                                      ), 
                                                    ), 
                                                  ), 
                                                  const SizedBox(width: 16), 
                                                  Expanded( 
                                                    child: ElevatedButton.icon( 
                                                      onPressed: _isDownloading ? null : _downloadPDF, 
                                                      icon: _isDownloading ? 
                                                      SizedBox( 
                                                        width: 20, 
                                                        height: 20, 
                                                        child: CircularProgressIndicator( 
                                                          strokeWidth: 2, 
                                                          color: Colors.white, ), 
                                                          ) 
                                                          : Icon(Icons.download), 
                                                          label: Text(_isDownloading ? 'Generating...' 
                                                          : "Download PDF"), 
                                                          style: ElevatedButton.styleFrom( 
                                                            padding: EdgeInsets.symmetric(vertical: 16), 
                                                            backgroundColor: AppConstants.primaryColor,
                                                             ), 
                                                            ), 
                                                          ), 
                                                        ], 
                                                      ), 
                                                      SizedBox(height: 20,), 
                                                      // Info Text 
                                                      if (_pdfFilePath != null) 
                                                      Container( 
                                                        padding: EdgeInsets.all(12), 
                                                        decoration: BoxDecoration( 
                                                          color: Colors.blue.shade50, 
                                                          borderRadius: BorderRadius.circular(8), 
                                                          border: Border.all(
                                                            color: Colors.blue.shade200),
                                                             ), 
                                                             child: Row( 
                                                              children: [
                                                                 Icon(Icons.info_outline, 
                                                                 color: Colors.blue.shade700, 
                                                                 size: 20, 
                                                                 ), 
                                                                 SizedBox(width: 8,), 
                                                                 Expanded( 
                                                                  child: Text( "PDF ready to share via Whatsapp, Email, or SMS", 
                                                                  style: TextStyle(
                                                                    fontSize: 12, 
                                                                    color: Colors.blue.shade700, 
                                                                    ), 
                                                                  ), 
                                                                ), 
                                                              ], 
                                                            ), 
                                                          ), 
                                                        ], 
                                                      ), 
                                                    ), 
                                                  ), 
                                                ); 
                                              } 
                                              Widget _buildReportItem(String text)
                                              { 
                                                return Padding( 
                                                  padding: EdgeInsets.only(bottom: 8), 
                                                  child: Text( text, 
                                                  style: TextStyle( 
                                                    fontSize: 14, 
                                                    color: Colors.grey.shade700, 
                                                    ), 
                                                  ),
                                                ); 
                                              }
                                            }
