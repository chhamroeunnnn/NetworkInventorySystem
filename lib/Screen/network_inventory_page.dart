import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectteam/widgethelp/sidebar.dart';
import 'package:projectteam/widgethelp/tableheader.dart';

class NetworkInventoryPage extends StatefulWidget {
  const NetworkInventoryPage({super.key});

  @override
  State<NetworkInventoryPage> createState() => _NetworkInventoryPageState();
}

class _NetworkInventoryPageState extends State<NetworkInventoryPage> {
  String searchText = "";

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          // ================= SIDEBAR =================
          Sidebar(currentPage: "Home", onLogout: () => logout(context)),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search by name, IP, or department",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.trim().toLowerCase();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TABLE HEADER
                  tableHeader(), // make sure your tableHeader includes Department column
                  // TABLE DATA
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('inventory')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Error loading devices"),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No devices found"));
                        }

                        final docs = snapshot.data!.docs;

                        return ListView(
                          children: docs
                              .where((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                final name = (data['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final ip = (data['ip'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final department = (data['department'] ?? '')
                                    .toString()
                                    .toLowerCase();

                                return name.contains(searchText) ||
                                    ip.contains(searchText) ||
                                    department.contains(searchText);
                              })
                              .map((doc) {
                                return tableRow(
                                  doc,
                                  context,
                                ); // update tableRow to show department
                              })
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
