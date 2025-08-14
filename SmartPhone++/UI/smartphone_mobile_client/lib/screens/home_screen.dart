import 'package:flutter/material.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/model/service.dart';
import 'package:smartphone_mobile_client/providers/product_provider.dart';
import 'package:smartphone_mobile_client/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  String? _error;
  final PageController _pageController = PageController();
  final TextEditingController _serviceNumberController = TextEditingController();
  bool _isCheckingService = false;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
    _pageController.addListener(() {
      setState(() {}); // Rebuild to update page indicator
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _serviceNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Initialize the base URL first
      await productProvider.initBaseUrl();
      
      // Get all products and filter for featured ones
      final allProducts = await productProvider.get();
      final featuredProducts = allProducts.items?.where((product) => product.isFeatured).toList() ?? [];
      
      setState(() {
        _featuredProducts = featuredProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkServiceStatus() async {
    final serviceNumber = _serviceNumberController.text.trim();
    if (serviceNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a service number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingService = true;
    });

    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.initBaseUrl();
      
      final service = await serviceProvider.getByServiceNumber(serviceNumber);
      
      if (!mounted) return;
      
      if (service != null) {
        _showServiceDetailsDialog(service);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service not found. Please check your service number.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking service: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingService = false;
        });
      }
    }
  }

  void _showServiceDetailsDialog(Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Service Status',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildServiceInfoRow('Service Number', service.description ?? 'N/A'),
                _buildServiceInfoRow('Service Name', service.name),
                _buildServiceInfoRow('Phone Model', service.phoneModel?.name ?? 'N/A'),
                _buildServiceInfoRow('Created Date', _formatDate(service.createdAt)),
                _buildServiceInfoRow('Estimated Duration', 
                  service.estimatedDuration != null 
                    ? '${service.estimatedDuration} hours' 
                    : 'N/A'),
                _buildServiceStatusRow('Status', service.status),
                if (service.technicianNotes != null && service.technicianNotes!.isNotEmpty)
                  _buildServiceInfoRow('Technician Notes', service.technicianNotes!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusRow(String label, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              'Error loading products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                _loadFeaturedProducts();
              },
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

    if (_featuredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No featured products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new featured products!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6, // Fixed height for slideshow
            child: PageView.builder(
              controller: _pageController,
              itemCount: _featuredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_featuredProducts[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          const Divider(height: 32, thickness: 1, color: Colors.grey),
          _buildServiceChecker(),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.grey[100],
                ),
                child: product.productImages != null && product.productImages!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: product.productImages!.first.imageData != null
                            ? FutureBuilder<Widget>(
                                future: _buildImageWidget(product.productImages!.first.imageData!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.purple,
                                      ),
                                    );
                                  }
                                },
                              )
                            : const Icon(
                                Icons.phone_android,
                                size: 80,
                                color: Colors.grey,
                              ),
                      )
                    : const Icon(
                        Icons.phone_android,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (product.brand != null) ...[
                      Text(
                        'Brand: ${product.brand}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (product.description != null) ...[
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.currentPrice != null) ...[
                          Text(
                            '\$${product.currentPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          if (product.originalPrice != null &&
                              product.originalPrice! > product.currentPrice!)
                            Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 16,
                          color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _featuredProducts.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == (_pageController.hasClients 
                  ? _pageController.page?.round() ?? 0 
                  : 0) 
                  ? Colors.purple 
                  : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChecker() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _serviceNumberController,
            decoration: InputDecoration(
              hintText: 'Enter service number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isCheckingService ? null : _checkServiceStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: _isCheckingService 
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Check Service Status'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildImageWidget(String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image,
            size: 80,
            color: Colors.grey,
          );
        },
      );
    } catch (e) {
      return const Icon(
        Icons.broken_image,
        size: 80,
        color: Colors.grey,
      );
    }
  }
}
