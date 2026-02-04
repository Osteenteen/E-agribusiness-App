import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color backgroundCream = Color(0xFFFDFDF5);

  // Controllers for the Add Crop popup
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  // Function to show the Add Crop Bottom Sheet
  void _showAddCropSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 24, right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New Crop", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Crop Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _unitController,
              keyboardType: TextInputType.number, // Shows the number pad
              decoration: InputDecoration(
                labelText: "Quantity (Units)",
                hintText: "Enter a number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveCropToFirebase,
                child: const Text("Save to Inventory", 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔥 THE QUICK FIX: Saving data with Integer conversion
  Future<void> _saveCropToFirebase() async {
    final String name = _nameController.text.trim();
    final String unitText = _unitController.text.trim();

    // Convert string input to integer safely
    final int? unitInt = int.tryParse(unitText);

    if (name.isNotEmpty && unitInt != null) {
      await FirebaseFirestore.instance.collection('crops').add({
        'name': name,
        'unit': unitInt, // Saves as Number in Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _unitController.clear();
      Navigator.pop(context); // Close the sheet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid name and a number for units")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        title: const Text("Crop Inventory", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      // Floating button to trigger the add sheet
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: _showAddCropSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('crops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }

          final crops = snapshot.data!.docs;

          if (crops.isEmpty) {
            return const Center(child: Text("No crops found. Tap + to add some!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final data = crops[index].data() as Map<String, dynamic>;
              final String name = data['name']?.toString() ?? "Unknown";
              final int unitValue = data['unit'] is int ? data['unit'] : 0;

              return _buildCropCard(name, unitValue);
            },
          );
        },
      ),
    );
  }

  Widget _buildCropCard(String name, int unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryGreen.withOpacity(0.1),
          child: const Icon(Icons.layers, color: primaryGreen),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Quantity: $unit units"), 
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            unit.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}