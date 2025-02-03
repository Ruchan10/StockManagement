import 'package:flutter/material.dart';

class SearchableFilterDropdown extends StatefulWidget {
  final String label;
  final String? selectedValue;
  final List<String> options;
  final Function(String?) onSelected;

  const SearchableFilterDropdown({
    Key? key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  @override
  _SearchableFilterDropdownState createState() =>
      _SearchableFilterDropdownState();
}

class _SearchableFilterDropdownState extends State<SearchableFilterDropdown> {
  late List<String> filteredOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.label}...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredOptions = widget.options
                                .where((option) => option
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      // Filtered List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredOptions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(filteredOptions[index]),
                              onTap: () {
                                widget.onSelected(filteredOptions[index]);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.selectedValue ?? widget.label,
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
