import 'dart:async';
import 'dart:developer';

import 'package:flutter_gps_device_tracking_app/screens/map_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
import 'package:flutter_gps_device_tracking_app/screens/welcome_screen.dart';
import 'package:flutter_gps_device_tracking_app/services/navigate_components.dart';
import 'package:flutter_gps_device_tracking_app/services/notification_services.dart';
import 'package:flutter_gps_device_tracking_app/services/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  PhoneModel? myPhone;
  bool loading = false;
  NotificationServices notificationServices = NotificationServices();
  DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
  dynamic myPhoneKey = "";
  late Timer myTimer;
  Future<void> getData() async {
    myPhoneKey = await SharedPreferAl.readStr('girisYapilanKisi');

    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    // ignore: use_build_context_synchronously
    notificationServices.firebaseInit(context);
    // ignore: use_build_context_synchronously
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    await didTakenIdGo().then((value) {
      if (value == true) {
        navigateReplace(context, const MapScreen());
      }
    });
  }

  Future<bool> didTakenIdGo() async {
    var myToken = await notificationServices.getDeviceToken();
    var mykey = await findPhone(myToken);
    var value = await refPhones.child(mykey.toString()).get();
    PhoneModel myModel =
        PhoneModel.fromJson(value.value as Map<dynamic, dynamic>?);
    log('device token');
    log(myToken);
    if (myModel.takenID != "") {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    myTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await didTakenIdGo().then((value) {
        if (value) {
          navigateReplace(context, const MapScreen());
        }
      });
    });
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    myTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Track My Device"),
          actions: [
            IconButton(
              onPressed: () {
                showQuitButton(context);
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (mounted) {
              setState(() {});
            }
          },
          child: Column(
            children: [
              Expanded(child: linkedDevices()),
              Expanded(flex: 10, child: phoneList()),
            ],
          ),
        ));
  }

  Future<dynamic> showQuitButton(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Çıkış Yap"),
          content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // AlertDialog'ı kapat
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // AlertDialog'ı kapat
                SharedPreferAl.saveBl('girisYapildi', false);
                navigateReplace(context, const WelcomePage());
              },
              child: const Text("Çıkış"),
            ),
          ],
        );
      },
    );
  }

  Row linkedDevices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Linked Devices",
            style: TextStyle(fontSize: 20),
          ),
        ),
        IconButton(
            onPressed: () {
              if (mounted) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.replay))
      ],
    );
  }

  FutureBuilder phoneList() {
    return FutureBuilder(
        future: refPhones.once(),
        builder: (context, event) {
          if (event.hasData) {
            List<PhoneModel> liste = <PhoneModel>[];
            var gelenDeger = event.data?.snapshot.value as dynamic;
            if (gelenDeger != null) {
              gelenDeger.forEach((key, nesne) {
                PhoneModel comedPhone = PhoneModel.fromJson(nesne);
                if (key != myPhoneKey) {
                  if (comedPhone.available == true) {
                    liste.add(comedPhone);
                  }
                } else {
                  if (comedPhone.takenID != null) {
                    myPhone = comedPhone;
                  }
                }
              });
              if (liste.isEmpty) {
                return const SizedBox(
                  child: Text("No Available Device"),
                );
              }
            }
            return ListView.builder(
                itemCount: liste.length,
                itemBuilder: (context, index) {
                  PhoneModel phone = liste[index];
                  return ListTile(
                    title: Text(phone.name.toString()),
                    subtitle: Text(phone.phoneID.toString()),
                    trailing: loading
                        ? const CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.blue,
                          )
                        : const SizedBox(),
                    onTap: loading
                        ? null
                        : () async {
                            await sendConnectNotification(
                                myPhone!, phone, myPhoneKey);
                            if (mounted) {
                              setState(() {
                                loading = true;
                              });
                            }
                            await Future.delayed(const Duration(seconds: 30));
                            await didTakenIdGo().then((value) {
                              if (value) {
                                navigateReplace(context, const MapScreen());
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("The request has timed out."),
                                ));
                              }
                            });
                            if (mounted) {
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                  );
                });
          }
          return const SizedBox(
            child: Text("No Data"),
          );
        });
  }
}
