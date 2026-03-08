import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/category.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class CategoryListingsScreen extends StatefulWidget {
  final Category category;
  final String? subcategoryId;
  final String? subcategoryName;

  const CategoryListingsScreen({
    super.key,
    required this.category,
    this.subcategoryId,
    this.subcategoryName,
  });

  @override
  State<CategoryListingsScreen> createState() => _CategoryListingsScreenState();
}

class _CategoryListingsScreenState extends State<CategoryListingsScreen> {
  String? _selectedSubcategoryId;
  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _selectedSubcategoryId = widget.subcategoryId;
    _fetchListings();
  }

  void _fetchListings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchListings(
        categoryId: widget.category.id,
        subcategoryId: _selectedSubcategoryId,
        filters: _filters,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedSubcategoryId != null
              ? (widget.category.subcategories
                        ?.firstWhere(
                          (s) => s.id == _selectedSubcategoryId,
                          orElse: () =>
                              SubCategory(id: '', name: widget.category.name),
                        )
                        .name ??
                    widget.category.name)
              : widget.category.name,
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.darkText),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Subcategory Filter (Image 2 Style)
          if (widget.category.subcategories != null &&
              widget.category.subcategories!.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.category.subcategories!.length + 1,
                itemBuilder: (context, index) {
                  final bool isAll = index == 0;
                  final subcat = isAll
                      ? null
                      : widget.category.subcategories![index - 1];
                  final bool isSelected = isAll
                      ? _selectedSubcategoryId == null
                      : _selectedSubcategoryId == subcat?.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        isAll ? 'All' : subcat!.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkText,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSubcategoryId = isAll ? null : subcat?.id;
                          });
                          _fetchListings();
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Action Bar: Sort & Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.sort,
                    label: 'Sort',
                    onTap: () {},
                  ),
                ),
                Container(height: 24, width: 1, color: Colors.grey[200]),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Filter',
                    onTap:
                        () {}, // To be implemented with category-specific filters
                  ),
                ),
              ],
            ),
          ),

          // Listings Grid
          Expanded(
            child: Consumer<MarketplaceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No listings found in this category',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: provider.listings.length,
                  itemBuilder: (context, index) {
                    return ListingCard(
                      listing: provider.listings[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListingDetailScreen(
                              listing: provider.listings[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.darkText),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
