import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gps_device_tracking_app/components/my_textfields.dart';
import 'package:flutter_gps_device_tracking_app/components/snackbar_show.dart';
import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gps_device_tracking_app/services/notification_services.dart';

class RegisterScreen extends StatefulWidget {
  final PageController pageController;
  const RegisterScreen({super.key, required this.pageController});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  NotificationServices notificationServices = NotificationServices();

  late TextEditingController controlPhoneID;
  late TextEditingController controlPassword;
  late TextEditingController controlPasswordAgain;
  late TextEditingController controlPhoneName;
  AutovalidateMode mode = AutovalidateMode.disabled;
  GlobalKey<FormState> formRegisterKey = GlobalKey<FormState>();

  Future<bool> addPhone() async {
    try {
      var value = await notificationServices.getDeviceToken();
      PhoneModel phoneModel = PhoneModel(
        token: value.toString(),
        phoneID: controlPhoneID.text.toString(),
        name: controlPhoneName.text.toString(),
        password: controlPassword.text.toString(),
        takenID: "",
        gpsInfo: GpsLocation(lat: "0", lng: "0"),
        available: true,
      );
      DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
      await refPhones.push().set(phoneModel.toJson());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Hata oluştu: $e");
      }
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    controlPassword = TextEditingController();
    controlPasswordAgain = TextEditingController();
    controlPhoneID = TextEditingController();
    controlPhoneName = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    controlPassword.dispose();
    controlPhoneID.dispose();
    controlPasswordAgain.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formRegisterKey,
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textFormFieldDefault(
                  mode: mode,
                  controller: controlPhoneID,
                  action: TextInputAction.next,
                  hint: "Phone ID",
                ),
                textFormFieldDefault(
                  mode: mode,
                  controller: controlPhoneName,
                  action: TextInputAction.next,
                  hint: "Phone Name",
                ),
                textFormPassword(mode: mode, controller: controlPassword),
                textFormPassword(mode: mode, controller: controlPasswordAgain),
                ElevatedButton(
                    onPressed: () async {
                      bool deger = formRegisterKey.currentState!.validate();
                      if (deger) {
                        if (controlPassword.text == controlPasswordAgain.text) {
                          await addPhone().then((value) {
                            if (value) {
                              controlPassword.clear();
                              controlPasswordAgain.clear();
                              controlPhoneID.clear();
                              controlPhoneName.clear();

                              snackBarGoster(context, "Register Successful");
                              widget.pageController.animateToPage(0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut);
                            } else {
                              snackBarGoster(context, "Register Failed");
                            }
                          });
                        } else {
                          snackBarGoster(context, "Please Write same password");
                        }
                      }
                    },
                    child: const Text("Register")),
                TextButton(
                    onPressed: () {
                      widget.pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut);
                    },
                    child: const Text("Already Have an Account?"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
