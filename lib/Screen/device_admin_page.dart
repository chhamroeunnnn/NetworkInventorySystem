import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectteam/login-page/Login.dart';
import 'package:projectteam/widgethelp/sidebar.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController departmentController =
      TextEditingController(); // ✅ New field

  String selectedStatus = 'Active';

  Future<void> saveDevice() async {
    if (nameController.text.isEmpty ||
        typeController.text.isEmpty ||
        ipController.text.isEmpty ||
        locationController.text.isEmpty ||
        departmentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('inventory').add({
        'name': nameController.text,
        'type': typeController.text,
        'ip': ipController.text,
        'location': locationController.text,
        'department': departmentController.text, // ✅ Save department
        'status': selectedStatus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device Added Successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving device: $e")));
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          Sidebar(currentPage: "Availability", onLogout: () => logout()),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Welcome Admin",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Icon(Icons.wb_sunny_outlined),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Device name & type
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          "Device name",
                          "Enter Device name",
                          nameController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildField(
                          "Device Type",
                          "Enter device type",
                          typeController,
                        ),
                      ),
                    ],
                  ),

                  // IP
                  _buildField("IP", "Enter your IP", ipController),

                  // Location
                  _buildField(
                    "Location",
                    "Enter your location",
                    locationController,
                  ),

                  // ✅ Department
                  _buildField(
                    "Department",
                    "Enter department name",
                    departmentController,
                  ),

                  // Status Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF10183D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: ['Active', 'Offline'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedStatus = value!),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F3F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save button
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: saveDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1535),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
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

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF10183D),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF1F3F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
