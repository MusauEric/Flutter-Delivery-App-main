import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:restaurant/Models/MapBox/DrivingResponse.dart';

class MapBoxController {

  final _url = 'https://api.mapbox.com/directions/v5';
  final _apikey = 'https://api.mapbox.com/styles/v1/erickmusa/ckzdpyzc4000z14myagkk2xy5/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXJpY2ttdXNhIiwiYSI6ImNremRvdmRvYjBjOWgzMnBkOHU1dWN1eDEifQ.SfI8UkS93k67vqp7OR-nTg';


  Future<DrivingResponse> getCoordsOriginAndDestinationDelivery(LatLng origin, LatLng destination) async {

    final coordString = '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

    final url = '$_url/mapbox/driving/$coordString';

    final resp = await http.get(Uri.parse('$url?alternatives=true&geometries=polyline6&steps=false&access_token=$_apikey&language=es'));

    return DrivingResponse.fromJson( jsonDecode( resp.body ) );

  }

}

final mapBoxController = MapBoxController();