import sys

with open('d:/ControlledCopy/Inidawish/mobile_app/lib/screens/marketplace/create_listing_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace category initialization
content = content.replace("String _selectedCategory = 'Electronics';", "String? _selectedCategory;\n  String? _selectedSubcategory;\n  String? _location;\n  List<String> _currentSubcategories = [];")

# Remove _categories array
categories_array = """  final List<String> _categories = [
    'Electronics',
    'Real Estate',
    'Vehicles',
    'Fashion',
    'Furniture',
  ];"""
content = content.replace(categories_array, "")

# Import geolocator
content = content.replace("import 'package:flutter/foundation.dart' show kIsWeb;", "import 'package:flutter/foundation.dart' show kIsWeb;\nimport 'package:geolocator/geolocator.dart';\nimport 'package:geocoding/geocoding.dart';")

# Add location getter in initState
init_state = """  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          setState(() {
            _location = "${placemarks.first.locality}, ${placemarks.first.administrativeArea}";
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _pickImages() async {"""
content = content.replace("  Future<void> _pickImages() async {", init_state)

# Replace Category dropdown
old_dropdown = """                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedCategory = val);
                            },
                          ),"""

new_dropdown = """                          Consumer<MarketplaceProvider>(
                            builder: (context, provider, child) {
                              return DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: provider.categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  );
                                }).toList(),
                                validator: (value) => value == null ? 'Please select a category' : null,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategory = val;
                                      _selectedSubcategory = null;
                                      final cat = provider.categories.firstWhere((c) => c.id == val);
                                      _currentSubcategories = cat.subcategories ?? [];
                                    });
                                  }
                                },
                              );
                            }
                          ),
                          if (_currentSubcategories.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedSubcategory,
                              decoration: const InputDecoration(
                                labelText: 'Subcategory',
                              ),
                              items: _currentSubcategories.map((subcat) {
                                return DropdownMenuItem(
                                  value: subcat,
                                  child: Text(subcat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSubcategory = val);
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: TextEditingController(text: _location),
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'e.g. New Delhi, Delhi',
                              prefixIcon: Icon(Icons.location_on, size: 20),
                            ),
                            onChanged: (val) => _location = val,
                          ),"""
content = content.replace(old_dropdown, new_dropdown)

# Replace provider postListing
old_post = """      final success = await provider.postListing({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category_id': _selectedCategory,
        'images': imageUrls,
      });"""

new_post = """      final success = await provider.postListing({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category_id': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'location': _location,
        'images': imageUrls,
      });"""
content = content.replace(old_post, new_post)

with open('d:/ControlledCopy/Inidawish/mobile_app/lib/screens/marketplace/create_listing_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
