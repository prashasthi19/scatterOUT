import 'package:flutter/material.dart';
import 'map_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of risk locations (replace later with API data)
    final List<Map<String, String>> alerts = [
      {'location': 'MG Road', 'risk': 'High'},
      {'location': 'Majestic Bus Stand', 'risk': 'Medium'},
      {'location': 'Cubbon Park', 'risk': 'Low'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 239, 184, 223),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: const Color.fromARGB(255, 239, 184, 223)),
              title: Text(alerts[index]['location']!),
              subtitle: Text('Risk Level: ${alerts[index]['risk']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 239, 184, 223),
        child: const Icon(Icons.map),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        },
      ),
    );
  }
}
