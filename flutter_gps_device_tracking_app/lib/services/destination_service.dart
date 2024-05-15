// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = "AIzaSyDM7L-zb82vaON0F7hGKKwd9BdqcAzGEj4";
  Future<Map<String, dynamic>> getDirection(
      String origin, String destination) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end _location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };
    return results;
  }
}
