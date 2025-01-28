import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(),
        body: ListView.builder(

          itemBuilder: (context, index) {
          return Container();
        }));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(
      kToolbarHeight * 4); // Set height for your custom AppBar

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomAppBarClipper(), // Custom clipper for your AppBar shape
      child: Container(
        color: MyColors.colorDarkPurple,
      ),
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // path.lineTo(0, 0); // 1. Point
    path.lineTo(0, h); //2. Point
    path.quadraticBezierTo(w * 0.5, h - 100, w, h); // 3. Point

    path.lineTo(w, h - 100); // 4. Point
    path.lineTo(w, 0); // 5. Point

    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MyColors {
  static Color colorDarkPurple = const Color(0xFF441752);
  static Color colorLightPurple = const Color(0xFF8174A0);
  static Color colorVeryLightPurple = const Color(0xFFA888B5);
  static Color colorVeryVeryLightPurple = const Color(0xFFD4BEE4);
}



//admin ko list dikhana hai crosponding to their 
