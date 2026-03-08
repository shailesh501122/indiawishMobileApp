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
                            if (category.icon != null &&
                                category.icon!.isNotEmpty)
                              Image.network(
                                category.icon!.startsWith('http')
                                    ? category.icon!
                                    : '${ApiConfig.baseUrl.replaceAll('/api', '')}${category.icon!.startsWith('/') ? '' : '/'}${category.icon!.replaceAll('\\', '/')}',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.category_outlined,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey,
                                  size: 24,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.grey[100]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
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
                                                      Icons.category_outlined,
                                                      color: AppColors.primary,
                                                      size: 22,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.category_outlined,
                                                color: AppColors.primary,
                                                size: 22,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      subcat.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkText,
                                        height: 1.2,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.05,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.primary,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'View All',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
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
