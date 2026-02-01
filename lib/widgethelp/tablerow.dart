import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget tableRow(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  final bool isActive = data['status'] == 'Active';

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(data['name'] ?? '')),
        Expanded(child: Text(data['type'] ?? '')),
        Expanded(child: Text(data['ip'] ?? '')),
        Expanded(child: Text(data['location'] ?? '')),

        // STATUS TOGGLE
        Expanded(
          child: GestureDetector(
            onTap: () {
              FirebaseFirestore.instance
                  .collection('inventory')
                  .doc(doc.id)
                  .update({'status': isActive ? 'Offline' : 'Active'});
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isActive ? 'Active' : 'Offline',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
