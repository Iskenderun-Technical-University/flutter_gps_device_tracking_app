class PhoneModel {
  String? phoneID;
  String? name;
  String? takenID;
  String? password;
  String? token;
  bool? available;
  GpsLocation? gpsInfo;

  PhoneModel({
    required this.token,
    required this.phoneID,
    required this.name,
    required this.takenID,
    required this.password,
    required this.available,
    required this.gpsInfo,
  });

  factory PhoneModel.fromJson(Map<dynamic, dynamic>? json) {
    return PhoneModel(
        token: json?['token'],
        phoneID: json?['phoneID'],
        name: json?['name'],
        takenID: json?['takenID'],
        password: json?['password'],
        available: json?['available'],
        gpsInfo: GpsLocation.fromJson(json?['gpsInfo']));
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'phoneID': phoneID,
      'name': name,
      'takenID': takenID,
      'password': password,
      'available': available,
      'gpsInfo': gpsInfo?.toJson(),
    };
  }
}

class GpsLocation {
  String? lat;
  String? lng;

  GpsLocation({
    required this.lat,
    required this.lng,
  });

  factory GpsLocation.fromJson(Map<dynamic, dynamic>? json) {
    return GpsLocation(
      lat: json?['lat'],
      lng: json?['lng'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
