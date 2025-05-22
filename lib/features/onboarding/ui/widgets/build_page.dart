import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double imageHeight;
  final double imageWidth;
  final double imageScale;


  const BuildPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageScale,
  }
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 12,top: 40,bottom: 12),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Section
            Image.asset(
              scale: imageScale,
              imagePath,
              height: imageHeight.h,
              width: imageWidth.w,// Adjust height as needed
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),

            // Title Section
            Text(
              style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontFamily: "Poppins",fontSize: 22,fontWeight: FontWeight.w600),
              title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),

            // Subtitle Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontFamily: "Poppins",fontSize: 16,),
                subtitle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
