
  import 'package:flutter/Material.dart';

Future<dynamic> navigateReplace(BuildContext context,Widget page) {
    return Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  page,
                                  ));
  }
  
Future<dynamic> navigate(BuildContext context,Widget page) {
    return Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  page,
                                  ));
  }
  