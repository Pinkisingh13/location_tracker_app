import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Location Tracker Admin', 
        debugShowCheckedModeBanner: false,
        home: UserIdScreen());
  }
}


class AdminUserHome extends StatefulWidget {
  const AdminUserHome({super.key, required this.userId});
  final String userId;

  @override
  State<AdminUserHome> createState() => _AdminUserHomeState();
}

class _AdminUserHomeState extends State<AdminUserHome> {
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  // Fetch and listen to the user's location from Firebase
  void fetchUserLocation() {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref("locations");
    ref.child(widget.userId).onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          userLocation = LatLng(data["latitude"], data["longitude"]);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracked User Location")),
      body: userLocation != null
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("trackedUser"),
                  position: userLocation!,
                ),
              },
            )
          : const Center(child: CircularProgressIndicator()),
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return AdminUserHome(
              userId: userId!,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter User ID Of The Person"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter the User ID to track:",
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