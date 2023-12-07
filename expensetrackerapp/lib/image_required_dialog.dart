import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ImageRequiredDialog extends StatelessWidget {

  final String heading;
  final String subheading;

  ImageRequiredDialog({required this.heading, required this.subheading});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.teal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Lottie.asset('assets/animations/image_req_animation.json'),
            ),
            Center(child: Text('$heading',style: TextStyle(fontSize: 20,color: Color(0xff99EDC3),fontWeight: FontWeight.bold),)),
            SizedBox(height: 5,),
            Center(child: Text('$subheading',style: TextStyle(fontSize: 12,color: Colors.white),)),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff99EDC3)
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }, child: Text('Okay',style: TextStyle(color: Colors.teal),)),
            )
          ],
        ),
      ),
    );
  }
}

void showImageRequiredDialog(BuildContext context, String heading, String subheading) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ImageRequiredDialog(heading: heading,subheading: subheading,);
    },
  );
}
