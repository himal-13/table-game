import 'package:flutter/material.dart';
import 'package:table_game/main.dart'; // Assuming the colors are defined here

// This is the new menu page to select tables to view.
class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  // A list to hold the numbers (tables) selected by the user
  final List<int> _selectedNumbers = [];

  // Toggles the selection of a number
  void _toggleNumber(int number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers.add(number);
      }
    });
  }

  // Navigates to the page that displays the selected multiplication tables
  void _viewTables() {
    if (_selectedNumbers.isNotEmpty) {
      // Sort the numbers for a consistent appearance
      _selectedNumbers.sort();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _TablesViewerPage(selectedNumbers: _selectedNumbers),
        ),
      );
    } else {
      // Show a snackbar if no numbers are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one number to view.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // A helper widget to build the number selection buttons
  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumbers.contains(number);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _toggleNumber(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? lightPurple : beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          minimumSize: const Size(60, 60), // Fixed size for square buttons
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : darkPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Tables',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Grid of number buttons
                Expanded( // Use Expanded to make the Wrap scrollable
                  child: SingleChildScrollView( // Add SingleChildScrollView
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(20, (index) => _buildNumberButton(index + 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // View Tables button
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: _viewTables,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 61, 205, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      'View Tables',
                      style: TextStyle(
                        color: darkPurple,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// This is the page that displays the selected multiplication tables.
class _TablesViewerPage extends StatelessWidget {
  final List<int> selectedNumbers;

  const _TablesViewerPage({required this.selectedNumbers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        title: const Text(
          "Multiplication Tables",
          style: TextStyle(color: beige, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkPurple,
        iconTheme: const IconThemeData(color: beige),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: selectedNumbers.length,
          itemBuilder: (context, index) {
            final int tableNumber = selectedNumbers[index];
            return _buildTableCard(tableNumber);
          },
        ),
      ),
    );
  }

  /// Helper widget to build a single card for a multiplication table.
  Widget _buildTableCard(int tableNumber) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: beige,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the table (e.g., "Table of 5")
            Text(
              "Table of $tableNumber",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            const Divider(color: darkPurple, thickness: 1),
            const SizedBox(height: 8),
            // Loop to generate each line of the multiplication table
            for (int i = 1; i <= 10; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "$tableNumber x $i = ${tableNumber * i}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: darkPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
