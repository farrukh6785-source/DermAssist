import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier{
  final Connectivity _connectivity;
  bool _isConnected = true;

  ConnectivityProvider(this._connectivity){
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async{
    try{
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result as List<ConnectivityResult>);
    } catch(e){
      debugPrint("Error checking connectivity: $e");
    }
  }
  void _updateConnectionStatus(List<ConnectivityResult> results){
    bool hasConnection = results.any((result) =>
    result == ConnectivityResult.mobile || result == ConnectivityResult.wifi ||
    result == ConnectivityResult.ethernet);

    if(_isConnected !=  hasConnection){
      _isConnected = hasConnection;
      notifyListeners();
    } 
  }
}