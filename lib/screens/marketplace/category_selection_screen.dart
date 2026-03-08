import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/marketplace_provider.dart';
import 'category_listings_screen.dart';
import '../../models/category.dart';

class CategorySelectionScreen extends StatefulWidget {
  final Category? initialCategory;

  const CategorySelectionScreen({super.key, this.initialCategory});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketplaceProvider>();
      provider.fetchCategories().then((_) {
        if (widget.initialCategory != null) {
          final index = provider.categories.indexWhere(
            (c) => c.id == widget.initialCategory!.id,
          );
          if (index != -1) {
            setState(() {
              _selectedCategoryIndex = index;
            });
          }
        }
      });
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
          icon: const Icon(Icons.close, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          final selectedCategory = provider.categories[_selectedCategoryIndex];

          return Row(
            children: [
              // Left Sidebar: Parent Categories
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(right: BorderSide(color: Colors.grey[200]!)),
                ),
                child: ListView.builder(
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    final isSelected = _selectedCategoryIndex == index;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: isSelected
                              ? const Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: 4,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            if (category.icon != null)
                              Image.network(
                                category.icon!,
                                width: 32,
                                height: 32,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.category_outlined,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey,
                                ),
                              )
                            else
                              Icon(
                                Icons.category_outlined,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Right Content: Subcategories Grid
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedCategory.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: 50,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 20,
                              ),
                          itemCount:
                              (selectedCategory.subcategories?.length ?? 0) + 1,
                          itemBuilder: (context, index) {
                            if (index <
                                (selectedCategory.subcategories?.length ?? 0)) {
                              final subcat =
                                  selectedCategory.subcategories![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryListingsScreen(
                                            category: selectedCategory,
                                            subcategoryId: subcat.id,
                                            subcategoryName: subcat.name,
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[100]!,
                                        ),
                                      ),
                                      child:
                                          subcat.icon != null &&
                                              subcat.icon!.isNotEmpty
                                          ? Image.network(
                                              subcat.icon!.startsWith('http')
                                                  ? subcat.icon!
                                                  : '${ApiConfig.baseUrl.replaceAll('/api', '')}${subcat.icon!.startsWith('/') ? '' : '/'}${subcat.icon!.replaceAll('\\', '/')}',
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons
                                                        .subdirectory_arrow_right,
                                                    color: AppColors.primary,
                                                    size: 24,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.subdirectory_arrow_right,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      subcat.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // "View All" button
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryListingsScreen(
                                            category: selectedCategory,
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[100]!,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'View All',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
