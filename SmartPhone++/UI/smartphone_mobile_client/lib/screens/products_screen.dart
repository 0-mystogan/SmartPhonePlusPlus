import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/model/category.dart';
import 'package:smartphone_mobile_client/providers/product_provider.dart';
import 'package:smartphone_mobile_client/providers/category_provider.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';
import 'package:smartphone_mobile_client/widgets/cart_fab.dart';
import 'package:smartphone_mobile_client/widgets/cart_icon.dart';
import 'package:smartphone_mobile_client/screens/cart_screen.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _error;
  
  // Filter states
  int? _selectedCategoryId;
  RangeValues _priceRange = const RangeValues(0.0, 1000.0);
  String _searchQuery = '';
  bool _showSearchBox = false;
  
  // Price range limits
  double _minPrice = 0.0;
  double _maxPrice = 1000.0;
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Search debounce timer
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize with safe default values
    _minPrice = 0.0;
    _maxPrice = 1000.0;
    _priceRange = RangeValues(_minPrice, _maxPrice);
    
    print('ProductsScreen initialized with price range: $_minPrice - $_maxPrice');
    
    _loadProducts();
    _loadCategories();
    
    // Ensure filters are applied after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _applyFilters();
        _validateFilterState();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Initialize the base URL first
      await productProvider.initBaseUrl();
      
      // Get all products
      final allProducts = await productProvider.get();
      
      setState(() {
        _allProducts = allProducts.items ?? [];
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
      
      // Calculate price range from actual products
      if (_allProducts.isNotEmpty) {
        final prices = _allProducts
            .where((p) => p.currentPrice != null && p.currentPrice! > 0)
            .map((p) => p.currentPrice!)
            .toList();
        if (prices.isNotEmpty) {
          _minPrice = prices.reduce((a, b) => a < b ? a : b);
          _maxPrice = prices.reduce((a, b) => a > b ? a : b);
          // Ensure min and max are different to avoid RangeSlider error
          if (_minPrice == _maxPrice) {
            _maxPrice = _minPrice + 100.0; // Add some range if min == max
          }
          // Ensure the current price range is within the new bounds
          _priceRange = RangeValues(
            _priceRange.start.clamp(_minPrice, _maxPrice),
            _priceRange.end.clamp(_minPrice, _maxPrice),
          );
          print('Price range updated: $_minPrice - $_maxPrice, current: ${_priceRange.start} - ${_priceRange.end}');
        } else {
          // Fallback values if no products have prices
          _minPrice = 0.0;
          _maxPrice = 1000.0;
          _priceRange = RangeValues(_minPrice, _maxPrice);
          print('Using fallback price range: $_minPrice - $_maxPrice');
        }
      } else {
        // Fallback values if no products
        _minPrice = 0.0;
        _maxPrice = 1000.0;
        _priceRange = RangeValues(_minPrice, _maxPrice);
        print('No products available, using fallback price range: $_minPrice - $_maxPrice');
      }
      
      // Apply filters after loading products
      _applyFilters();
      _validateFilterState();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      
      // Initialize the base URL first
      await categoryProvider.initBaseUrl();
      
      // Get active categories
      final categories = await categoryProvider.getActiveCategories();
      
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      print('Error loading categories: $e');
    }
  }

  void _applyFilters() {
    print('Applying filters: Category: $_selectedCategoryId, Price: ${_priceRange.start.round()}-${_priceRange.end.round()}, Search: "$_searchQuery"');
    
    // Safety check: ensure price range is valid before filtering
    if (_minPrice >= _maxPrice || 
        _priceRange.start < _minPrice || 
        _priceRange.end > _maxPrice) {
      print('Invalid price range detected, resetting to safe values');
      _minPrice = 0.0;
      _maxPrice = 1000.0;
      _priceRange = RangeValues(_minPrice, _maxPrice);
    }
    
    final filtered = _allProducts.where((product) {
      // Category filter
      if (_selectedCategoryId != null && product.categoryId != _selectedCategoryId) {
        return false;
      }
      
      // Price range filter
      final price = product.currentPrice ?? 0;
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = product.name.toLowerCase();
        final description = product.description?.toLowerCase() ?? '';
        final brand = product.brand?.toLowerCase() ?? '';
        
        if (!name.contains(query) && 
            !description.contains(query) && 
            !brand.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    print('Filtered products: ${filtered.length} out of ${_allProducts.length}');
    
    // Update state with filtered results and force rebuild
    if (mounted) {
      setState(() {
        _filteredProducts = filtered;
      });
      
      // Force a rebuild of the filters section
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          _validateFilterState();
        }
      });
    }
  }

  void _forceRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategoryId != null || 
           _searchQuery.isNotEmpty || 
           (_priceRange.start > _minPrice || _priceRange.end < _maxPrice);
  }

  void _validateFilterState() {
    print('Validating filter state:');
    print('  Category: $_selectedCategoryId');
    print('  Search: "$_searchQuery"');
    print('  Price range: ${_priceRange.start.round()}-${_priceRange.end.round()}');
    print('  Price limits: ${_minPrice.round()}-${_maxPrice.round()}');
    print('  Has active filters: ${_hasActiveFilters()}');
    print('  Filtered products: ${_filteredProducts.length} out of ${_allProducts.length}');
  }

  void _rebuildScreen() {
    if (mounted) {
      setState(() {});
      print('Screen rebuilt');
    }
  }

  void _resetFilters() {
    print('Resetting all filters');
    setState(() {
      _selectedCategoryId = null;
      // Ensure we have valid price range values
      if (_minPrice < _maxPrice) {
        _priceRange = RangeValues(_minPrice, _maxPrice);
      } else {
        // Fallback to safe values
        _minPrice = 0.0;
        _maxPrice = 1000.0;
        _priceRange = RangeValues(_minPrice, _maxPrice);
      }
      _searchQuery = '';
      _searchController.clear();
      _showSearchBox = false;
    });
    
    // Apply filters after resetting state
    _applyFilters();
    _forceRefresh();
  }

  void _toggleSearchBox() {
    setState(() {
      _showSearchBox = !_showSearchBox;
      if (_showSearchBox) {
        _searchFocusNode.requestFocus();
      } else {
        _searchQuery = '';
        _searchController.clear();
        _applyFilters();
        _forceRefresh();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    // Set new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('Search query applied: "$_searchQuery"');
      _applyFilters();
      _forceRefresh();
    });
  }

  void _addToCart(Product product) async {
    try {
      final cartManager = Provider.of<CartManagerProvider>(context, listen: false);
      
      // Initialize base URL if not already done
      await cartManager.initBaseUrl();
      
      // Add product to cart (cart will be created automatically if needed)
      await cartManager.addToCart(product);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: const Text('Webshop'),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              floating: false,
              actions: [
                // Search button
                IconButton(
                  icon: Icon(_showSearchBox ? Icons.close : Icons.search),
                  onPressed: _toggleSearchBox,
                  tooltip: _showSearchBox ? 'Close search' : 'Search products',
                ),
                const CartIcon(),
              ],
            ),
            
            // Search box (conditional)
            if (_showSearchBox)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by name, description, or brand...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            
            // Filters section - collapsible
            SliverPersistentHeader(
              pinned: true, // Changed from false to true to keep filters visible
              delegate: _FiltersSliverHeaderDelegate(
                child: Container(
                  key: ValueKey('filters_section_${_selectedCategoryId}_${_searchQuery}_${_priceRange.start.round()}_${_priceRange.end.round()}'),
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter header with reset button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Show active filters indicator
                              if (_hasActiveFilters())
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange[300]!),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reset'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      
                      // Category filter
                      if (_isLoadingCategories) ...[
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Loading categories...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else if (_categories.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedCategoryId != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                key: ValueKey('selected_category_${_selectedCategoryId}'),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.purple[300]!),
                                ),
                                child: Text(
                                  '${_categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => Category(id: 0, name: 'Unknown', createdAt: DateTime.now())).name} selected',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length + 1, // +1 for "All" option
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // "All" option
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    key: ValueKey('category_all_${_selectedCategoryId == null}'),
                                    label: const Text('All'),
                                    selected: _selectedCategoryId == null,
                                    onSelected: (selected) {
                                      print('Category "All" selected');
                                      setState(() {
                                        _selectedCategoryId = null;
                                      });
                                      _applyFilters();
                                      _forceRefresh();
                                    },
                                    selectedColor: Colors.purple[100],
                                    checkmarkColor: Colors.purple[700],
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: _selectedCategoryId == null ? Colors.purple[700] : Colors.grey[700],
                                      fontWeight: _selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    elevation: _selectedCategoryId == null ? 4 : 1,
                                    shadowColor: Colors.purple.withOpacity(0.3),
                                  ),
                                );
                              }
                              
                              final category = _categories[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  key: ValueKey('category_${category.id}_${_selectedCategoryId == category.id}'),
                                  label: Text(category.name),
                                  selected: _selectedCategoryId == category.id,
                                  onSelected: (selected) {
                                    print('Category "${category.name}" selected: $selected');
                                    setState(() {
                                      _selectedCategoryId = selected ? category.id : null;
                                    });
                                    _applyFilters();
                                    _forceRefresh();
                                  },
                                  selectedColor: Colors.purple[100],
                                  checkmarkColor: Colors.purple[700],
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: _selectedCategoryId == category.id ? Colors.purple[700] : Colors.grey[700],
                                    fontWeight: _selectedCategoryId == category.id ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  elevation: _selectedCategoryId == category.id ? 4 : 1,
                                  shadowColor: Colors.purple.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Price range filter
                      const Text(
                        'Price Range (BAM)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            // Current price range display
                            if (_minPrice < _maxPrice && 
                                _priceRange.start >= _minPrice && 
                                _priceRange.end <= _maxPrice)
                              Container(
                                key: ValueKey('price_display_${_priceRange.start.round()}_${_priceRange.end.round()}'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.purple[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Min: ${_priceRange.start.round()} BAM',
                                      style: TextStyle(
                                        color: Colors.purple[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Max: ${_priceRange.end.round()} BAM',
                                      style: TextStyle(
                                        color: Colors.purple[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            // Range slider
                            if (_minPrice < _maxPrice && 
                                _priceRange.start >= _minPrice && 
                                _priceRange.end <= _maxPrice)
                              RangeSlider(
                                key: ValueKey('slider_${_priceRange.start.round()}_${_priceRange.end.round()}'),
                                values: _priceRange,
                                min: _minPrice,
                                max: _maxPrice,
                                divisions: 100,
                                activeColor: Colors.purple,
                                inactiveColor: Colors.purple[100],
                                labels: RangeLabels(
                                  '${_priceRange.start.round()} BAM',
                                  '${_priceRange.end.round()} BAM',
                                ),
                                onChanged: (RangeValues values) {
                                  print('Price range changed: ${values.start.round()}-${values.end.round()}');
                                  // Ensure the new values are within valid bounds
                                  final clampedStart = values.start.clamp(_minPrice, _maxPrice);
                                  final clampedEnd = values.end.clamp(_minPrice, _maxPrice);
                                  
                                  setState(() {
                                    _priceRange = RangeValues(clampedStart, clampedEnd);
                                  });
                                  _applyFilters();
                                  _forceRefresh();
                                },
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Price range not available or invalid',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Results count
            SliverToBoxAdapter(
              child: Container(
                key: ValueKey('results_count_${_filteredProducts.length}_${_allProducts.length}'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Text(
                      '${_filteredProducts.length} product${_filteredProducts.length != 1 ? 's' : ''} found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_filteredProducts.length != _allProducts.length)
                      Text(
                        ' (filtered from ${_allProducts.length})',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Products grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildProductsSliver(),
            ),
          ],
        ),
      ),
      floatingActionButton: const CartFAB(),
    );
  }

  Widget _buildProductsSliver() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _allProducts.isEmpty ? Icons.inventory_2_outlined : Icons.filter_list_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _allProducts.isEmpty ? 'No products available' : 'No products match your filters',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (_allProducts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      key: ValueKey('products_grid_${_filteredProducts.length}'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Default for small screens
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product, const BoxConstraints(maxWidth: 400));
        },
        childCount: _filteredProducts.length,
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.purple,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _allProducts.isEmpty ? Icons.inventory_2_outlined : Icons.filter_list_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _allProducts.isEmpty ? 'No products available' : 'No products match your filters',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_allProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine grid layout based on screen width
          int crossAxisCount = 2; // Default for small screens
          double childAspectRatio = 0.8; // Increased aspect ratio to make cards more compact
          
          if (constraints.maxWidth > 600) {
            // Medium screens (tablets)
            crossAxisCount = 3;
            childAspectRatio = 0.85;
          }
          if (constraints.maxWidth > 900) {
            // Large screens (large tablets)
            crossAxisCount = 4;
            childAspectRatio = 0.9;
          }
          if (constraints.maxWidth > 1200) {
            // Extra large screens
            crossAxisCount = 5;
            childAspectRatio = 0.95;
          }

          return GridView.builder(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: constraints.maxWidth > 600 ? 20 : 16,
              mainAxisSpacing: constraints.maxWidth > 600 ? 20 : 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildProductCard(product, constraints);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth <= 600;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Stack(
        children: [
          // Main product card content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container - fixed height to prevent overflow
              Container(
                height: 100, // Reduced height from 120 to 100 for more compact cards
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isSmallScreen ? 12 : 16),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    // Product image
                    product.productImages != null && product.productImages!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isSmallScreen ? 12 : 16),
                            ),
                            child: product.productImages!.first.imageData != null
                                ? Image.memory(
                                    base64Decode(product.productImages!.first.imageData!),
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                    
                    // Cart icon overlay on top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product information container - flexible height
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Brand
                      if (product.brand != null && product.brand!.isNotEmpty)
                        Text(
                          product.brand!,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Hanging price tag on the right side
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${product.currentPrice?.toStringAsFixed(2) ?? '0.00'} BAM',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate for the filters section
class _FiltersSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  
  _FiltersSliverHeaderDelegate({required this.child});
  
  @override
  double get minExtent => 380.0; // Increased minimum height to prevent overflow
   
  @override
  double get maxExtent => 380.0; // Increased maximum height to prevent overflow
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Always rebuild to ensure filters update visually
    return true;
  }
}
