import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/constants.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _location;
  List<SubCategory> _currentSubcategories = [];

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  // ─── New Feature Fields ───────────────────────────────────────────────
  String _listingType = 'sell'; // 'sell' or 'rent'
  final _rentPriceController = TextEditingController();
  String _rentPeriod = 'monthly';
  Map<String, dynamic>? _priceSuggestion;
  bool _loadingSuggestion = false;
  final _apiService = ApiService();
  File? _videoFile;
  bool _isUploadingVideo = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchCategories();
    });
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _location =
              "${place.locality ?? ''}${place.locality != null && place.administrativeArea != null ? ', ' : ''}${place.administrativeArea ?? ''}";
          _locationController.text = _location!;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          final remainingSlots = 5 - _selectedImages.length;
          if (images.length > remainingSlots) {
            _selectedImages.addAll(images.take(remainingSlots));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Only the first 5 images total were selected'),
              ),
            );
          } else {
            _selectedImages.addAll(images);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      if (video != null) {
        setState(() => _videoFile = File(video.path));
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  void _removeVideo() {
    setState(() => _videoFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Post New Ad'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Uploading images and posting ad...',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Photo section header
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Add Photos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedImages.length}/5',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              if (_selectedImages.length < 5)
                                GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    width: 90,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        style: BorderStyle.solid,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_a_photo_outlined,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Add Photo',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ..._selectedImages.asMap().entries.map((entry) {
                                final index = entry.key;
                                final image = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 90,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image: kIsWeb
                                              ? NetworkImage(image.path)
                                                    as ImageProvider
                                              : FileImage(File(image.path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Video section
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Video (Max 30s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_videoFile == null)
                          GestureDetector(
                            onTap: _pickVideo,
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_call_outlined, color: AppColors.primary, size: 30),
                                  SizedBox(height: 4),
                                  Text(
                                    'Select Video Ad',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Stack(
                            children: [
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.videocam, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Video Selected', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeVideo,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Form fields
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ad Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Sell / Rent Toggle ────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Row(
                              children: [
                                _buildTypeBtn('sell', '🏷️  Sell'),
                                _buildTypeBtn('rent', '🔄  Rent Out'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title *',
                              hintText: 'What are you selling?',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter a title'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              hintText: 'Describe your item in detail',
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter a description'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // ── Price fields: sell price or rent price ────
                          if (_listingType == 'sell') ...[                          
                            TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹) *',
                                hintText: 'e.g. 5000',
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter a price';
                                if (double.tryParse(value) == null)
                                  return 'Please enter a valid number';
                                return null;
                              },
                            ),
                            // 🤖 AI Price Suggestion Banner
                            if (_priceSuggestion != null && (_priceSuggestion!['similar_count'] ?? 0) > 0)
                              GestureDetector(
                                onTap: () {
                                  _priceController.text = '${_priceSuggestion!['recommended_price']}';
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Similar items sell for ₹${_priceSuggestion!['min_price']} – ₹${_priceSuggestion!['max_price']}. Tap to use ₹${_priceSuggestion!['recommended_price']}',
                                          style: const TextStyle(color: Colors.blue, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_loadingSuggestion)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                                    SizedBox(width: 8),
                                    Text('Fetching price suggestion...', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                                  ],
                                ),
                              ),
                          ] else ...[  // listing_type == 'rent'
                            TextFormField(
                              controller: _rentPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Rent Price (₹) *',
                                hintText: 'e.g. 500',
                                prefixText: '₹ ',
                                suffixText: '/ period',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_listingType == 'rent' && (value == null || value.isEmpty))
                                  return 'Please enter rent price';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _rentPeriod,
                              decoration: const InputDecoration(labelText: 'Rent Period'),
                              items: const [
                                DropdownMenuItem(value: 'daily', child: Text('Per Day')),
                                DropdownMenuItem(value: 'weekly', child: Text('Per Week')),
                                DropdownMenuItem(value: 'monthly', child: Text('Per Month')),
                              ],
                              onChanged: (val) { if (val != null) setState(() => _rentPeriod = val); },
                            ),
                            // Also need a listing price (deposit or reference)
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Deposit / Refundable Amount (₹)',
                                hintText: 'e.g. 5000',
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter deposit amount';
                                if (double.tryParse(value) == null) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Consumer<MarketplaceProvider>(
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
                                validator: (value) =>
                                    value == null ? 'Please select a category' : null,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategory = val;
                                      _selectedSubcategory = null;
                                      final cat = provider.categories.firstWhere((c) => c.id == val);
                                      _currentSubcategories = cat.subcategories ?? [];
                                    });
                                    _fetchPriceSuggestion();
                                  }
                                },
                              );
                            },
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
                                  value: subcat.id,
                                  child: Text(subcat.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedSubcategory = val);
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'e.g. New Delhi, Delhi',
                              prefixIcon: Icon(Icons.location_on, size: 20),
                            ),
                            onChanged: (val) => _location = val,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Post Ad Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<MarketplaceProvider>();
      final imageUrls = await provider.uploadImages(_selectedImages);

      if (imageUrls.isEmpty) throw Exception('Failed to upload images');

      String? videoUrl;
      if (_videoFile != null) {
        setState(() => _isUploadingVideo = true);
        videoUrl = await provider.uploadVideo(_videoFile!);
        setState(() => _isUploadingVideo = false);
      }

      final success = await provider.postListing({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category_id': _selectedCategory,
        'subcategory_id': _selectedSubcategory,
        'location': _location,
        'images': imageUrls,
        'listing_type': _listingType,
        if (_listingType == 'rent') 'rent_price': double.tryParse(_rentPriceController.text) ?? 0,
        if (_listingType == 'rent') 'rent_period': _rentPeriod,
        if (videoUrl != null) 'video_url': videoUrl,
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad posted successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to post ad. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _rentPriceController.dispose();
    super.dispose();
  }

  /// Sell / Rent toggle button builder
  Widget _buildTypeBtn(String type, String label) {
    final isSelected = _listingType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _listingType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  /// Fetches AI price suggestion when category is selected
  Future<void> _fetchPriceSuggestion() async {
    if (_selectedCategory == null) return;
    setState(() { _loadingSuggestion = true; _priceSuggestion = null; });
    final result = await _apiService.suggestPrice(
      categoryId: _selectedCategory!,
      subcategoryId: _selectedSubcategory,
    );
    if (mounted) setState(() { _priceSuggestion = result; _loadingSuggestion = false; });
  }
}
