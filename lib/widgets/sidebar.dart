// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const Sidebar({
    super.key, 
    required this.selectedFilter, 
    required this.onFilterChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildFilterButton('All', Icons.dashboard),
          _buildFilterButton('Math', Icons.calculate),
          _buildFilterButton('Physics', Icons.science),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, IconData icon) {
    final isSelected = selectedFilter == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.teal : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.teal : Colors.black)),
      selected: isSelected,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => onFilterChanged(title), // Tells the main screen the filter changed!
    );
  }
}