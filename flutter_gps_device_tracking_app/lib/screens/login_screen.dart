import 'package:flutter/material.dart';
import 'package:flutter_gps_device_tracking_app/components/my_textfields.dart';
import 'package:flutter_gps_device_tracking_app/components/snackbar_show.dart';
import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
import 'package:flutter_gps_device_tracking_app/screens/home_page.dart';
import 'package:flutter_gps_device_tracking_app/services/navigate_components.dart';
import 'package:flutter_gps_device_tracking_app/services/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  final PageController pageController;
  const LoginScreen({super.key, required, required this.pageController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

int input = 0;

class _LoginScreenState extends State<LoginScreen> {
  bool progressBar = false;
  bool passwordShow = true;
  late TextEditingController controlPhoneID;
  late TextEditingController controlPassword;
  AutovalidateMode mode = AutovalidateMode.disabled;
  GlobalKey<FormState> formRegisterKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    controlPhoneID = TextEditingController();
    controlPassword = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    controlPassword.dispose();
    controlPhoneID.dispose();
  }

  Future<void> searchPhone(String phoneID, String sifre) async {
    DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
    refPhones.onValue.listen((event) {
      var gelenDeger = event.snapshot.value as Map?;
      if (gelenDeger != null) {
        gelenDeger.forEach((key, nesne) {
          PhoneModel comePhone = PhoneModel.fromJson(nesne);

          if (comePhone.phoneID == phoneID && comePhone.password == sifre) {
            input = 1;
            List<String> deger = [
              key,
              comePhone.name.toString(),
              comePhone.phoneID.toString(),
              comePhone.gpsInfo?.lat.toString() ?? "0",
              comePhone.gpsInfo?.lng.toString() ?? "0",
              comePhone.takenID.toString()
            ];

            snackBarGoster(context, "Giriş Başarılı! Hoşgeldin ${deger[1]}");

            SharedPreferAl.saveBl('girisYapildi', true);
            SharedPreferAl.saveStr('girisYapilanKisi', key);
            SharedPreferAl.saveList("girisBilgi", deger);
            navigateReplace(context, const HomePage());
          }
        });
        input == 0
            ? snackBarGoster(context, "Kullanıcı veya şifre hatalı!")
            : null;
        setState(() {
          progressBar = !progressBar;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formRegisterKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: textFormFieldDefault(
                    hint: "Phone ID",
                    errorText: "Please Write Phone ID",
                    action: TextInputAction.next,
                    controller: controlPhoneID,
                    mode: mode),
              ),
              SizedBox(width: 300, child: passwordTextForm()),
              Visibility(
                  visible: progressBar,
                  child: const CircularProgressIndicator()),
              ElevatedButton(
                  onPressed: () {
                    bool deger = formRegisterKey.currentState!.validate();

                    if (deger) {
                      setState(() {
                        progressBar = !progressBar;
                      });
                      searchPhone(controlPhoneID.text, controlPassword.text);
                    }
                  },
                  child: const Text("Login")),
              TextButton(
                  onPressed: () {
                    widget.pageController.animateToPage(2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  child: const Text("Dont u have an account? Register Phone"))
            ],
          ),
        ),
      ),
    );
  }

  TextFormField passwordTextForm() {
    return TextFormField(
      decoration: InputDecoration(
        suffixIcon: IconButton(
            icon: Icon(passwordShow ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                passwordShow = !passwordShow;
              });
            }),
        hintText: "Password",
      ),
      obscureText: passwordShow,
      textInputAction: TextInputAction.done,
      controller: controlPassword,
      validator: (value) {
        if (value!.length <= 5) {
          mode = AutovalidateMode.onUserInteraction;
          return "Please Write Password at least 6 characters.";
        }
        return null;
      },
    );
  }
}
