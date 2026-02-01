import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectteam/widgethelp/sidebar.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  String searchText = "";
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController managerController = TextEditingController();
  final TextEditingController floorController = TextEditingController();

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> addDepartment() async {
    if (departmentController.text.isEmpty ||
        managerController.text.isEmpty ||
        floorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('departments').add({
      'department': departmentController.text,
      'manager': managerController.text,
      'floor': floorController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    departmentController.clear();
    managerController.clear();
    floorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Department added"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteDepartment(String docId) async {
    await FirebaseFirestore.instance
        .collection('departments')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Department deleted"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> editDepartment(
    String docId,
    String currentManager,
    String currentFloor,
  ) async {
    final managerEdit = TextEditingController(text: currentManager);
    final floorEdit = TextEditingController(text: currentFloor);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Department"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: managerEdit,
              decoration: const InputDecoration(labelText: "Manager"),
            ),
            TextField(
              controller: floorEdit,
              decoration: const InputDecoration(labelText: "Floor"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('departments')
                  .doc(docId)
                  .update({
                    'manager': managerEdit.text,
                    'floor': floorEdit.text,
                  });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Department updated"),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// 🔑 Count devices in inventory by matching department field
  Stream<int> componentCount(String departmentName) {
    return FirebaseFirestore.instance
        .collection('inventory')
        .where('department', isEqualTo: departmentName) // ✅ match by department
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          Sidebar(currentPage: "Departments", onLogout: () => logout(context)),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Departments Inventory",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SEARCH BAR
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by department or manager",
                      filled: true,
                      fillColor: Color(0xFFF1F3F4),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim().toLowerCase();
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // ADD FORM
                  Row(
                    children: [
                      Expanded(
                        child: _buildField("Department", departmentController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField("Manager", managerController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField("Floor", floorController)),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: addDepartment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // TABLE HEADER
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Department",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Manager",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Floor",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Components",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          "Actions",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // TABLE DATA
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('departments')
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
                            child: Text("Error loading departments"),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No departments found"),
                          );
                        }

                        final docs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final dept = (data['department'] ?? '')
                              .toString()
                              .toLowerCase();
                          final manager = (data['manager'] ?? '')
                              .toString()
                              .toLowerCase();
                          return dept.contains(searchText) ||
                              manager.contains(searchText);
                        }).toList();

                        return ListView(
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final departmentName = data['department'] ?? '';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(departmentName)),
                                  Expanded(child: Text(data['manager'] ?? '')),
                                  Expanded(child: Text(data['floor'] ?? '')),

                                  // 🔑 Live component count by department
                                  Expanded(
                                    child: StreamBuilder<int>(
                                      stream: componentCount(departmentName),
                                      builder: (context, countSnapshot) {
                                        if (!countSnapshot.hasData)
                                          return const Text("0");
                                        return Text("${countSnapshot.data}");
                                      },
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => editDepartment(
                                          doc.id,
                                          data['manager'] ?? '',
                                          data['floor'] ?? '',
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            deleteDepartment(doc.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
