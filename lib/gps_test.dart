import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'moving_window.dart';

class GpsTest extends StatefulWidget {
  @override
  _GpsTestState createState() => _GpsTestState();
}

class _GpsTestState extends State<GpsTest> {
  List<Position> points = new List();
  double totalDist = 0.0;
  MovingWindowSpeed avgSpeed = MovingWindowSpeed.withCapacity(10);

  Geolocator geoLocator = Geolocator();

  @override
  void initState() {
    super.initState();

    var locationOptions = LocationOptions(timeInterval: 1000);

    // Do I need this?
    // Maybe as a starting loop before the actual starting of the measuring
    // in order to "warm-up"?
//    geoLocator.getCurrentPosition().then((p) {
//      avgSpeed.add(p.speed);
//      points.add(p);
//    });

    geoLocator.getPositionStream(locationOptions).listen((Position position) {
      setState(() {
        if (points.length > 0) {
          calcDistance(points.last, position);
        }
        avgSpeed.add(position.speed);
        points.add(position);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GPS Test"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 4,
            child: Center(
              child: Text(
                "${totalDist.toStringAsFixed(2).padLeft(5, "0")} km\n"
                "${avgSpeed.getKmH()} km/h\n"
                "${avgSpeed.getMinKm()} min/km",
                style: Theme.of(context).textTheme.display1,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: points.length,
                itemBuilder: (context, idx) {
                  Position pos = points[idx];
                  return ListTile(
                    title: Text(
                        "(${pos.longitude.toStringAsFixed(4)},${pos.latitude.toStringAsFixed(4)}) (~${pos.accuracy.toStringAsFixed(2)} m)"),
                    subtitle: Text("${pos.speed * 3.6} km/h"),
                    trailing: Text(
                        "${pos.timestamp.hour}:${pos.timestamp.minute}:${pos.timestamp.second}"),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            points.clear();
            avgSpeed.clear();
            totalDist = 0.0;
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }

  void calcDistance(Position last, Position current) async {
    var distInMeters = await geoLocator.distanceBetween(
        last.latitude, last.longitude, current.latitude, current.longitude);

    var distInKm = distInMeters / 1000;

    totalDist += distInKm;
  }
}
