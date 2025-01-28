import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'location tracking User',
      debugShowCheckedModeBanner: false,

      home: UserIdScreen(),
    );
  }
}



class TrackedUserHome extends StatefulWidget {
  const TrackedUserHome({super.key, required this.userId});
  final String userId;

  @override
  State<TrackedUserHome> createState() => _TrackedUserHomeState();
}

class _TrackedUserHomeState extends State<TrackedUserHome> {

  // init state to request location permission
  @override
  void initState() {
    super.initState();
    _requestLocationPermission(context); // Request permission before sharing location
  }

  // Request location permissions
  Future<void> _requestLocationPermission(BuildContext context) async {
    if (await Permission.location.isDenied) {
      final status = await Permission.location.request();
      if (mounted && status.isDenied) {
          // Show error message if permission is denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission is required.")),
          ); 
      
        return;
      }
    }

    // Start sharing location if permissions are granted
    if (await Permission.location.isGranted) {
      startSharingLocation();
    } else {
      // Handle permanently denied permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Permission permanently denied. Enable it in settings."),
        ),
      );
      openAppSettings();
    }
  }

  // Continuously fetch and share location
  void startSharingLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Trigger update if user moves 2 meters
      ),
    ).listen((Position position) {
      shareLocationToFirebase(position, widget.userId);
    });
  }

  // Update location to Firebase
  Future<void> shareLocationToFirebase(Position position, String userId) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("locations/$userId");
      await ref.set({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      });
      print("Location updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sharing Location")),
      body: const Center(
        child: SizedBox(
          width: 250,
          child: Text(
            "Your location is being shared in real-time.",
            style: TextStyle(fontSize: 23),
          ),
        ),
      ),
    );
  }
}

class UserIdScreen extends StatefulWidget {
  const UserIdScreen({super.key});

  @override
  State<UserIdScreen> createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  final userIdController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? userId;

  void saveuserId() {
    if (formKey.currentState!.validate()) {
      setState(() {
        userId = userIdController.text.trim();
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return TrackedUserHome(
            userId: userId!,
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User Id"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create the User ID",
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "User ID",
                ),
                controller: userIdController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "user id can not be empty";
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () => saveuserId(),
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
