// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
            sound: channel.sound);

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msj') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message.notification!.title.toString()),
            content: Text("${message.notification!.body}Want to connect u"),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                  child: const Text("Yes!!"),
                  onPressed: () {
                    updatePhoneStatus(message);
                    Navigator.pop(context);
                  }),
            ],
          );
        },
      );
      // PUSH PAGE
    } else if (message.data['type'] == 'alert') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message.notification!.title.toString()),
            content:
                Text("${message.notification!.body}Want to know where are u"),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                  child: const Text("Okay!!"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        },
      );
      // PUSH PAGE
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

//message.data['bodyText']
Future<void> updatePhoneStatus(RemoteMessage message) async {
  DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
  NotificationServices notificationServices = NotificationServices();

  refPhones.once().then((value) async {
    //Map? gelenDeger = value.snapshot.value as Map?;
    log(message.data['bodyText']);
    String jsonString = message.data['bodyText'] as String;
    Map<dynamic, dynamic> bodyTextMap =
        json.decode(jsonString) as Map<dynamic, dynamic>;
    PhoneModel myPhone = PhoneModel.fromJson(bodyTextMap);
    var myPhoneKey = await findPhone(myPhone.token ?? "0");
    var myTargetKey =
        await findPhone(await notificationServices.getDeviceToken());
    var myPhoneReference = await refPhones.child(myPhoneKey.toString()).get();
    var myTargetReference = await refPhones.child(myTargetKey.toString()).get();
    PhoneModel myPhoneModel =
        PhoneModel.fromJson(myPhoneReference.value as Map);
    PhoneModel myTargetModel =
        PhoneModel.fromJson(myTargetReference.value as Map);

    myPhoneModel.takenID = myTargetModel.token;
    myPhoneModel.available = false;
    myTargetModel.takenID = myPhoneModel.token;
    myTargetModel.available = false;
    await refPhones.child(myPhoneKey.toString()).set(myPhoneModel.toJson());
    await refPhones.child(myTargetKey.toString()).set(myTargetModel.toJson());
  });
}

Future<String?> findPhone(String token) async {
  DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");

  var event = await refPhones.once();

  var gelenDeger = event.snapshot.value as Map?;
  if (gelenDeger != null) {
    for (var entry in gelenDeger.entries) {
      PhoneModel comePhone = PhoneModel.fromJson(entry.value);
      if (comePhone.token == token) {
        // ignore: prefer_interpolation_to_compose_strings
        log("THE KEY IS " + entry.key);
        return entry.key;
      }
    }
  }
  return null;
}

/*

  refPhones.once().then((event) {
    var gelenDeger = event.snapshot.value as Map?;
    if (gelenDeger != null) {
      String? myPhoneKey;
      gelenDeger.forEach((key, nesne) {
        log(message.data['bodyText']);
        String jsonString = message.data['bodyText'] as String;
        Map<dynamic, dynamic> bodyTextMap =
            json.decode(jsonString) as Map<dynamic, dynamic>;
        PhoneModel myPhone = PhoneModel.fromJson(bodyTextMap);

        PhoneModel comePhone = PhoneModel.fromJson(nesne);
        if (myPhone.token == comePhone.token) {
          myPhoneKey = key;
        }
      });
    }
  });
*/

sendConnectNotification(
    PhoneModel myPhone, PhoneModel phone, String myPhoneKey) async {
  var data = {
    'to': phone.token.toString(),
    'notification': {
      'title': 'New Phone Request',
      'body': '${phone.name} wants to connect with you',
    },
    'data': {'type': 'msj', 'id': myPhoneKey, "bodyText": myPhone.toJson()}
  };
  await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Bearer AAAATKaeUxM:APA91bHHyXpnhj4xve_AMy2aNBt--6ik0-QlZ0g6bSNDnOhp0MaXVMvGPQ4ZE_WY9AfBoy5JkmMczzVIa2NglnQAtTx4Zl6bhLlUwjeKgvd9XqWBmXOVArYXR2sdoROQIi_dIbWNaVP-'
      });
}

sendNotification(
    PhoneModel myPhone, PhoneModel phone, String myPhoneKey) async {
  var data = {
    'to': phone.token.toString(),
    'notification': {
      'title': 'Incoming Alert',
      'body': '${phone.name} wants to know where are u',
    },
    'data': {'type': 'alert', 'id': myPhoneKey, "bodyText": myPhone.toJson()}
  };
  await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Bearer AAAATKaeUxM:APA91bHHyXpnhj4xve_AMy2aNBt--6ik0-QlZ0g6bSNDnOhp0MaXVMvGPQ4ZE_WY9AfBoy5JkmMczzVIa2NglnQAtTx4Zl6bhLlUwjeKgvd9XqWBmXOVArYXR2sdoROQIi_dIbWNaVP-'
      });
}
