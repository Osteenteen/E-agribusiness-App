import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketDashboard extends StatefulWidget {
  const MarketDashboard({super.key});

  @override
  State<MarketDashboard> createState() => _MarketDashboardState();
}

class _MarketDashboardState extends State<MarketDashboard> {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color backgroundCream = Color(0xFFFDFDF5);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  // Function to show the "Add Product" sheet
  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 24, right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add to Marketplace", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)),
            const SizedBox(height: 20),
            _buildTextField(_nameController, "Product Name (e.g. Tomatoes)", Icons.shopping_basket_outlined),
            const SizedBox(height: 12),
            _buildTextField(_priceController, "Price (e.g. 150)", Icons.payments_outlined, isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_unitController, "Unit (e.g. 1kg Bag)", Icons.scale_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _saveProduct,
                child: const Text("Post Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Save logic with Integer parsing for Price
  Future<void> _saveProduct() async {
    final String name = _nameController.text.trim();
    final int? price = int.tryParse(_priceController.text.trim());
    final String unit = _unitController.text.trim();

    if (name.isNotEmpty && price != null && unit.isNotEmpty) {
      await FirebaseFirestore.instance.collection('market').add({
        'name': name,
        'price': price, // Saved as Integer
        'unit': unit,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      _priceController.clear();
      _unitController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid name and price")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        title: const Text("Marketplace", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: _showAddProductSheet,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('market').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading market data"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryGreen));

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text("Market is empty. Be the first to sell!"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              return _buildProductCard(data['name'], data['price'], data['unit']);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String name, int price, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, color: Colors.orange, size: 40),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text("Ksh $price", style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}