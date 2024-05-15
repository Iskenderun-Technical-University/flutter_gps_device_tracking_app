import 'package:flutter_gps_device_tracking_app/models/phone_model.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gps_device_tracking_app/screens/map_page.dart';

Set<Marker> createMarker(context, PhoneModel? targetPhone, markerbitmap) {
  return <Marker>{
    Marker(
      onTap: () {
        DestinationDeger.latlng = LatLng(
            double.parse(targetPhone?.gpsInfo?.lat ?? "0"),
            double.parse(targetPhone?.gpsInfo?.lng ?? "0"));
      },
      markerId: const MarkerId("0"),
      position: LatLng(double.parse(targetPhone?.gpsInfo?.lat ?? "0"),
          double.parse(targetPhone?.gpsInfo?.lng ?? "0")),
      icon: markerbitmap,
      infoWindow: InfoWindow(
        title: targetPhone?.name ?? "Phone Name",
        snippet: targetPhone?.phoneID ?? "Phone ID",
      ),
    ),
  };
}
