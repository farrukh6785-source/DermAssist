import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermassist_fyp/models/user_model.dart';


enum AuthStatus{
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}
class AuthProvider with ChangeNotifier {
 final firebase.FirebaseAuth _auth;
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  firebase.User? _firebaseUser;
  User? _appUser;
  AuthStatus _status = AuthStatus.uninitialized;
  // Constructor
  AuthProvider(): _auth = firebase.FirebaseAuth.instance{
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }
  // Getters
  AuthStatus get status => _status;
  User? get user => _appUser;
  firebase.User? get firebaseUser => _firebaseUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Liste to auth state changes from Firebase
  Future<void> _onAuthStateChanged(firebase.User? firebaseUser) async{
    if(firebaseUser == null){
      _status = AuthStatus.unauthenticated;
      _appUser = null;
      notifyListeners();
    }else{
      _firebaseUser = firebaseUser;
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if(doc.exists){
        final data = doc.data()!;
       String? location;
        double? lat;
        double? lng;

      if (data['location'] != null && data['location'] is Map) {
  final loc = Map<String, dynamic>.from(data['location']);

  location = loc['address'];
  lat = (loc['lat'] as num?)?.toDouble();
  lng = (loc['lng'] as num?)?.toDouble();
        }
        _appUser = User(
          id: firebaseUser.uid, 
          fullName: data['fullName'] ?? firebaseUser.displayName?? 'User',
          email: data['email'] ?? firebaseUser.email ?? 'user@example.com',
          dateOfBirth: data['dob'] != null
          ? (data['dob'] as Timestamp).toDate()
          : DateTime(1990, 1,1),
           age: data['age'] ?? 30,
           //profilePhotoUrl: data['profilePhotoUrl'] ?? firebaseUser.photoURL,
           profilePhotoUrl: (data['profilePhotoUrl'] !=null && data['profilePhotoUrl'] !='') 
           ? data['profilePhotoUrl'] : firebaseUser.photoURL,
            location: location ?? 'Not specified',
            latitude: lat,
            longitude: lng,
           );
      } else {
        _appUser = User(
          id: firebaseUser.uid, 
          fullName: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? 'user@example.com',
          dateOfBirth: DateTime(1990,1,1), 
          age: 30,
          profilePhotoUrl: firebaseUser.photoURL,
          );

          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'fullName' : _appUser!.fullName,
            'email' : _appUser!.email,
            'dob': Timestamp.fromDate(_appUser!.dateOfBirth),
            'age': _appUser!.age,
            'profilePhotoUrl': _appUser!.profilePhotoUrl ?? '',
          });
      }
           
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }
  // Email/Password Registration
  Future<String?> registerWithEmailAndPassword({
    required String email,
   required String password,
   required String fullName,
   required DateTime dob,
  }) async{
    try{
      _status = AuthStatus.authenticating;
      notifyListeners();

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = result.user;
      // Update Display name
      await _firebaseUser?.updateDisplayName(fullName);

      // Calculate Age
      final age = DateTime.now().year - dob.year;
      // In real app, save additional info to firebase here
      await _firestore.collection('users').doc(_firebaseUser!.uid).set({
        'fullName': fullName,
        'email': email,
        'dob': Timestamp.fromDate(dob),
        'age': age,
        'profilePhotoUrl': '',
      });
      
      return null; //
    } on firebase.FirebaseAuthException catch(e){
      _status= AuthStatus.unauthenticated;
      notifyListeners();
      return e.message;
      
    }
  }
  // Email/Password Login
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try{
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
        );
        _status = AuthStatus.authenticated;
          notifyListeners();
        return true;
    } on firebase.FirebaseAuthException catch(e){
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
      
    }
  }
  // Google Sing In
  Future<String?> signInWithGoogle() async{
    try{
      
      _status = AuthStatus.authenticating;
      notifyListeners();
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          if(googleUser == null){
          _status = AuthStatus.unauthenticated;
        notifyListeners();
        return 'Google sign in canceled';
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      _firebaseUser = result.user;
      
      // Save user to Firestore if not exists
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if(!doc.exists){
        await _firestore.collection('users').doc(_firebaseUser!.uid).set({
          'fullName' : _firebaseUser!.displayName ?? 'User',
          'email': _firebaseUser!.email ?? '',
          'dob': Timestamp.fromDate(DateTime(1990, 1, 1)),
          'age' : 30,
          'profilePhotoUrl' : _firebaseUser!.photoURL ?? '',
        });
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return null;
 } catch(e){
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return e.toString();
    }
  }
 // Change Password 
 Future<String?> changePassword({
required String currentPassword,
required String newPassword,
 }) async {
  try{
    final user = firebase.FirebaseAuth.instance.currentUser;
    if(user == null) return "User not logged in";
    final credential = firebase.EmailAuthProvider.credential(
      email: user.email!, 
      password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
  } catch(e){
    return "Error: $e";
  }
 }
  // Password Reset
  Future<String?> sendPasswordResetEmail(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email:email);
      return null;
    } on firebase.FirebaseAuthException catch(e){
      return e.message;
    }
  }

  // Logout
  Future<void> signOut() async{
    try{
      await GoogleSignIn().signOut();
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();

    final bool onboarded = prefs.getBool("onboarding_complete") ?? false;
    await prefs.clear();
    await prefs.setBool("onboarding_complete", onboarded);

    _status = AuthStatus.unauthenticated;
    _appUser = null;
    _firebaseUser = null;
    notifyListeners();
    } catch(e){
      print("Logout error: $e");
    }
 }

 // Delete Account
 Future<String?> deleteAccount() async{
  try{
    final user = firebase.FirebaseAuth.instance.currentUser;
    if(user == null){
      return "No user logged in";
    }
    String uid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await user.delete();
    try{
      await user.delete();
    } catch(e){
      return "Re-authentication required before deleting accont";
    }
    await GoogleSignIn().signOut();
    await firebase.FirebaseAuth.instance.signOut();
    return null;
  } catch (e){
    return "Error deleting account: $e";
  }
 }
  // Update Profile Image
  Future<void> updateProfileImage(String imageUrl) async{
    final user = _auth.currentUser;
    if(user !=null){
      await user.updatePhotoURL(imageUrl);
      await _firestore.collection('users').doc(user.uid).set({'profilePhotoUrl':imageUrl}, SetOptions(merge: true));
      _appUser = _appUser?.copyWith(profilePhotoUrl:imageUrl);
      notifyListeners();
    }
  }

  // Update Profile
  Future<String?> updateProfile({
    required String name,
    //required String phone,
    String? location,
  }) async{
    try{
      final user = firebase.FirebaseAuth.instance.currentUser;
      if(user == null){
        return "User not logged in";
      }
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        //'LocationText': location,
        'updateAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.reload();
      _firebaseUser = firebase.FirebaseAuth.instance.currentUser;
      notifyListeners();
      return null;
    } catch(e){
      return "Update failed: $e";
    }
  }
  Future<void> updateUserLocation(double lat, double lng, String address) async{
    final firebaseUser = _auth.currentUser;
    if(firebaseUser == null) return;
    final userId = _firebaseUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
      'location':{
        'lat': lat,
        'lng': lng,
        'address': address,
      }
    }, SetOptions(merge: true)
    );
    // Update local user object
    _appUser = _appUser?.copyWith(
      location: address,
      latitude: lat,
      longitude: lng,
    );
    notifyListeners();
  }
}