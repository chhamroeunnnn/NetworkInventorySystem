import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget tableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    color: Colors.grey[200],
    child: const Row(
      children: [
        Expanded(child: Text("Name")),
        Expanded(child: Text("Type")),
        Expanded(child: Text("IP")),
        Expanded(child: Text("Location")),
        Expanded(child: Text("Department")), // ✅ New column
        Expanded(child: Text("Status")),
        Expanded(child: Text("Action")),
      ],
    ),
  );
}

Widget tableRow(QueryDocumentSnapshot doc, BuildContext context) {
  final data = doc.data() as Map<String, dynamic>;
  bool isOnline = (data['status'] == 'Online');

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(data['name'] ?? '')),
        Expanded(child: Text(data['type'] ?? '')),
        Expanded(child: Text(data['ip'] ?? '')),
        Expanded(child: Text(data['location'] ?? '')),
        Expanded(child: Text(data['department'] ?? '')), // ✅ Show department
        // Status Toggle
        Expanded(
          child: Row(
            children: [
              Switch(
                value: isOnline,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('inventory')
                      .doc(doc.id)
                      .update({'status': value ? 'Online' : 'Offline'});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Status changed to ${value ? 'Online' : 'Offline'}",
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Delete Action
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete device",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: Text(
                    "Are you sure you want to delete '${data['name']}'?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseFirestore.instance
                    .collection('inventory')
                    .doc(doc.id)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Device deleted successfully")),
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}
