// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gps_device_tracking_app/components/snackbar_show.dart';
import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
import 'package:flutter_gps_device_tracking_app/screens/home_page.dart';
import 'package:flutter_gps_device_tracking_app/services/navigate_components.dart';
import 'package:flutter_gps_device_tracking_app/services/notification_services.dart';
import 'package:flutter_gps_device_tracking_app/services/shared_preferences.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/destination_service.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/set_markers.dart';

class DestinationDeger {
  static LatLng? latlng;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
  late Timer myTimer;
  NotificationServices notificationServices = NotificationServices();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  PhoneModel? targetPhone;
  PhoneModel? myPhone;
  String? myPhoneKey;
  Future<void> savePhoneLocationToDatabase(LocationData? locationData) async {
    String myPhoneKey = await SharedPreferAl.readStr("girisYapilanKisi");

    refPhones.once().then((event) async {
      var gelenDeger = event.snapshot.value as Map?;
      if (gelenDeger != null) {
        gelenDeger.forEach((key, nesne) async {
          myPhone = PhoneModel.fromJson(nesne);

          if (key == myPhoneKey) {
            myPhone?.gpsInfo?.lat = locationData?.latitude.toString();
            myPhone?.gpsInfo?.lng = locationData?.longitude.toString();
            refPhones.child(key).set(myPhone?.toJson());
            log("UPDATE IT");
            await getTargetPhone();
          }
        });
      }
    });
  }

  Future<PhoneModel> getPhoneInfo() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var myToken = await messaging.getToken();
    var mykey = await findPhone(myToken!);
    var myPhoneMap = await refPhones.child(mykey.toString()).get();
    PhoneModel myModel =
        PhoneModel.fromJson(myPhoneMap.value as Map<dynamic, dynamic>);
    return myModel;
  }

  Future<void> getTargetPhone() async {
    DatabaseReference refPhones = FirebaseDatabase.instance.ref("phones");
    refPhones.once().then((event) async {
      var gelenDeger = event.snapshot.value as Map?;
      if (gelenDeger != null) {
        gelenDeger.forEach((key, nesne) async {
          PhoneModel cPhone = PhoneModel.fromJson(nesne);
          NotificationServices notificationServices = NotificationServices();
          var yourToken = await notificationServices.getDeviceToken();
          log("MY TOKEN IS : $yourToken");

          if (yourToken == cPhone.takenID) {
            // ignore: prefer_interpolation_to_compose_strings
            log("FOUND IT" + key);
            targetPhone = cPhone;
            // ignore: use_build_context_synchronously
            myMarkers = createMarker(context, cPhone, markerbitmap);
            if (mounted) {
              setState(() {});
            }
          }
        });
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

  Future<bool> disconnectDevice() async {
    if (myPhone != null && targetPhone != null) {
      String? myKey = await SharedPreferAl.readStr('girisYapilanKisi');
      await getPhoneInfo().then((value) {
        myPhone = value;
      });
      myPhone!.available = true;
      myPhone!.takenID = "";

      log("Found my Key $myKey");
      await refPhones.child(myKey!).set(myPhone?.toJson());

      targetPhone!.takenID = "";
      targetPhone!.available = true;

      String? targetKey = await findPhone(targetPhone!.token.toString());
      log("Found Target Key $targetKey");
      await refPhones.child(targetKey!).set(targetPhone!.toJson());
      // ignore: use_build_context_synchronously
      snackBarGoster(context, "Disconnected");
      return true;
    } else {
      scaffoldKey.currentState?.closeDrawer();
      snackBarGoster(context, "Error");
      return false;
    }
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LocationService mapService = LocationService();
  Location location = Location();
  LocationData? _locationData;
  final Set<Polyline> _polylines = <Polyline>{};
  int _polylineIdCounter = 1;

  late BitmapDescriptor markerbitmap;

  void _setPolyLine(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()));
  }

  Future<void> addMapIcon() async {
    markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/map_icon.png",
    );
  }

  Future<void> getLocation() async {
    bool? serviceEnabled;
    PermissionStatus? permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData getLocation = await location.getLocation();
    if (mounted) {
      setState(() {
        _locationData = getLocation;
      });
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      moveCamera();
      if (mounted) {
        setState(() {
          _locationData = currentLocation;
        });
      }
    });
  }

  Future<void> moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    if (_locationData != null) {
      controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          zoom: 19,
        ),
      ));
    }
  }

  @override
  void initState() {
    getLocation();
    addMapIcon();
    myTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      savePhoneLocationToDatabase(_locationData);
      await didTakenIdGo().then((value) {
        if (!value) {
          navigateReplace(context, const HomePage());
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    myTimer.cancel();
  }

  Set<Marker> myMarkers = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            targetPhone == null
                ? const CircularProgressIndicator()
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      border: Border.all(),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Connected Device Name:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(targetPhone?.name.toString() ?? ""),
                              const SizedBox(height: 8),
                              const Text(
                                "Connected Device ID:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(targetPhone?.phoneID.toString() ?? ""),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text("Do you want to disconnect?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await disconnectDevice().then((value) {
                                  if (value) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(context);
                                    navigateReplace(context, const HomePage());
                                  }
                                });
                              },
                              child: const Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Disconnect',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    myPhoneKey =
                        await SharedPreferAl.readStr('girisYapilanKisi');
                    if (myPhone != null &&
                        targetPhone != null &&
                        myPhoneKey != null) {
                      await sendNotification(
                          myPhone!, targetPhone!, myPhoneKey!);
                    } else {
                      // ignore: use_build_context_synchronously
                      snackBarGoster(context, "Error");
                    }
                  },
                  child: const Text('Send Notification'),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          FloatingActionButton(
            heroTag: "1",
            backgroundColor: Colors.red,
            onPressed: () {
              log("${_locationData?.latitude ?? "0"}, ${_locationData?.longitude ?? "0"}");
              log("${DestinationDeger.latlng?.latitude},${DestinationDeger.latlng?.longitude}");

              if (_polylines.isNotEmpty) {
                DestinationDeger.latlng = null;
                snackBarGoster(context, "Siliniyor");
              }
              _polylines.clear();
            },
            child: const Icon(Icons.cancel),
          ),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          FloatingActionButton(
            heroTag: "2",
            onPressed: () async {
              if (DestinationDeger.latlng?.latitude == null) {
                snackBarGoster(context, "Lütfen bir konum seçiniz!");
              } else {
                _polylines.clear();
                snackBarGoster(context, "Yol tarifi alınıyor...");
                var directions = await mapService.getDirection(
                    "${_locationData?.latitude ?? "0"}, ${_locationData?.longitude ?? "0"}",
                    "${DestinationDeger.latlng?.latitude},${DestinationDeger.latlng?.longitude}");
                _setPolyLine(directions['polyline_decoded']);
              }
            },
            child: const Icon(Icons.turn_right_sharp),
          ),
        ],
      ),
      body: _locationData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onTap: (argument) {
                log(argument.toString());
              },
              polylines: _polylines,
              markers: myMarkers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(_locationData!.latitude!, _locationData!.longitude!),
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) async {
                savePhoneLocationToDatabase(_locationData);
                //_controller.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
