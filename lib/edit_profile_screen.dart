import 'package:dermassist_fyp/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/providers/auth_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class EditProfileScreen extends StatefulWidget{
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;

  File? _selectedImage;
  bool _isUploading = false;

  double? _lat;
  double? _lng;

  @override
  void initState(){
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _locationController = TextEditingController(
      text: user?.location ?? ''
    );
    _locationController = TextEditingController(text: user?.location ?? '');
  _getCurrentLocation();
  }
  

  @override
  void dispose(){
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if(_formKey.currentState!.validate()){
      try{
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await authProvider.updateProfile(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
        );

        if(_lat != null && _lng != null){
          await authProvider.updateUserLocation(_lat!, _lng!, _locationController.text.trim());
        }

        if(!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pop(context);

      } catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void>_pickAndUploadImage() async{
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Capture Photo"),
              onTap: () async{
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera);
                if(picked != null){
                  _uploadImage(File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Select from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if(picked != null){
                  _uploadImage(File(picked.path));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void>_uploadImage(File image) async{
    try{
      setState(() => _isUploading = true);

      final cloudName = "daxt6ffml";
      final uploadPreset = "profile_preset";

      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      var response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resBody);
        String imageUrl = data['secure_url'];

        await Provider.of<AuthProvider>(context, listen: false)
            .updateProfileImage(imageUrl);

        setState(() {
          _selectedImage = image;
          _isUploading = false;
        });

      } else {
        throw Exception("Upload failed");
      }

    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;

    final address =
        "${place.street}, ${place.locality}, ${place.country}";

    setState(() {
      _locationController.text = address;
      _lat = position.latitude;
      _lng = position.longitude;
    });

  } catch (e) {
    debugPrint("Location error: $e");
  }
}


  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final user = Provider.of<AuthProvider>(context).user;

  if (user != null) {
    // ✅ auto-sync UI with provider
   // _locationController.text = user.location ?? '';
  if (_locationController.text.isEmpty && user?.location != null) {
  _locationController.text = user!.location!;
}

    _lat = user.latitude;
    _lng = user.longitude;
  }
}

  Widget build (BuildContext context){
    final user = Provider.of<AuthProvider>(context).user;
    final imageUrl = user?.profilePhotoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade400,
                      backgroundImage: _selectedImage !=null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (imageUrl != null && imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.isAbsolute == true)
                          ? NetworkImage(imageUrl)
                          : null
                    ),
                    if(_isUploading)
                      const CircularProgressIndicator(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: _pickAndUploadImage,
                        icon: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () async {

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerScreen(),
                        ),
                      );

                      if(result != null){
                        final lat = result['lat'];
                        final lng = result['lng'];
                        final address = result['address'] ?? "Unknown Location";

                        setState(() {
                          _locationController.text = address;
                          _lat = lat;
                          _lng = lng;
                        });

                        await Provider.of<AuthProvider>(context, listen: false)
                            .updateUserLocation(lat, lng, address);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
