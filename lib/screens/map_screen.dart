import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  bool _loading = true;

  Set<Circle> _riskCircles = {};
  double _pulseValue = 0;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _listenForAlerts();
    _startPulseAnimation();
  }

  // 🧭 Get user’s current location
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      setState(() => _loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        setState(() => _loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permanently denied')),
      );
      setState(() => _loading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  // 🔥 Listen for Firestore updates
  void _listenForAlerts() {
    FirebaseFirestore.instance.collection('alerts').snapshots().listen((snapshot) {
      Set<Circle> newCircles = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('location') && data['location'] != null) {
          final lat = data['location']['lat'];
          final lng = data['location']['lng'];
          final status = data['risk_level'] ?? 'NO RISK';

          if (status.toUpperCase() == "RISK") {
            // 🔴 Pulsating danger zone
            newCircles.add(
              Circle(
                circleId: CircleId(doc.id),
                center: LatLng(lat, lng),
                radius: 200 + _pulseValue, // animated
                strokeColor: Colors.red.withOpacity(0.8),
                fillColor: Colors.red.withOpacity(0.3),
                strokeWidth: 2,
              ),
            );
            newCircles.add(
              Circle(
                circleId: CircleId('${doc.id}_glow'),
                center: LatLng(lat, lng),
                radius: 250 + _pulseValue,
                strokeColor: Colors.red.withOpacity(0.2),
                fillColor: Colors.red.withOpacity(0.15),
                strokeWidth: 0,
              ),
            );
          } else {
            // 🟢 Calm static safe zone
            newCircles.add(
              Circle(
                circleId: CircleId(doc.id),
                center: LatLng(lat, lng),
                radius: 100,
                strokeColor: Colors.green.withOpacity(0.6),
                fillColor: Colors.green.withOpacity(0.3),
                strokeWidth: 1,
              ),
            );
          }
        }
      }

      setState(() {
        _riskCircles = newCircles;
      });
    });
  }

  // 💓 Create pulsating animation
  void _startPulseAnimation() {
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      setState(() {
        _pulseValue = 20 * math.sin(DateTime.now().millisecondsSinceEpoch / 300.0);
      });
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Risk Map'),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Could not fetch location'))
              : GoogleMap(
                  onMapCreated: (controller) => _controller.complete(controller),
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  circles: _riskCircles,
                ),
    );
  }
}
