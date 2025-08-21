import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/providers/auth_provider.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class StripePaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const StripePaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = true;
  bool _paymentCompleted = false;
  String? _orderNumber;

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.purple, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                )
              : _paymentCompleted
              ? buildPaymentSuccessScreen()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: buildPaymentForm(context),
                ),
        ),
      ),
    );
  }

  Widget buildPaymentSuccessScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success message
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.purple[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your order has been placed successfully.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (_orderNumber != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Order #$_orderNumber',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummaryCard(),
          const SizedBox(height: 24),
          _buildBillingSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.purple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.05),
                  Colors.purple.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${widget.totalAmount.toStringAsFixed(2)} BAM',
                  style: TextStyle(
                    color: Colors.purple[800],
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.cartItems.length} Item${widget.cartItems.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cart items preview
          if (widget.cartItems.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Items in your order:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.cartItems.take(3).map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(2)} BAM',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
            if (widget.cartItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${widget.cartItems.length - 3} more items',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Billing Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'name',
            'Full Name',
            initialValue: _getUserFullName(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'email',
            'Email',
            initialValue: _getUserEmail(),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'address',
            'Address',
            initialValue: '123 Main Street',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'city',
                  'City',
                  initialValue: 'Sarajevo',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('state', 'State', initialValue: 'FBiH'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'country',
                  'Country',
                  initialValue: 'Bosnia and Herzegovina',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'pincode',
                  'ZIP Code',
                  keyboardType: TextInputType.number,
                  isNumeric: true,
                  initialValue: '71000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserFullName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'John Doe';
  }

  String _getUserEmail() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      return user.email ?? 'user@example.com';
    }
    return 'user@example.com';
  }

  Widget _buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              FormBuilderValidators.numeric(
                errorText: 'This field must be numeric',
              ),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              if (name == 'email')
                FormBuilderValidators.email(
                  errorText: 'Please enter a valid email address.',
                ),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          "Proceed to Payment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final formData = formKey.currentState?.value;

            try {
              await _processStripePayment(formData!);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // Stripe Payment Methods
  Future<void> initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      // Create a real payment intent
      final data = await createPaymentIntent(
        amount: (widget.totalAmount * 100).round().toString(),
        currency: 'BAM',
        name: formData['name'],
        email: formData['email'],
        address: formData['address'],
        pin: formData['pincode'],
        city: formData['city'],
        state: formData['state'],
        country: formData['country'],
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'SmartPhone++',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String email,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      // Get the secret key from environment variables
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      if (secretKey == null) {
        throw Exception('STRIPE_SECRET_KEY not found in environment variables');
      }

      // First, create a customer
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': email,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
        },
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to create customer: ${customerResponse.body}');
      }

      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      // Create ephemeral key
      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) {
        throw Exception(
          'Failed to create ephemeral key: ${ephemeralKeyResponse.body}',
        );
      }

      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      // Create payment intent
      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'SmartPhone++ Order Payment',
          'metadata[name]': name,
          'metadata[email]': email,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
          'metadata[items_count]': widget.cartItems.length.toString(),
          'metadata[total_amount]': widget.totalAmount.toString(),
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
          'amount': amount,
          'currency': currency,
        };
      } else {
        throw Exception(
          'Failed to create payment intent: ${paymentIntentResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    try {
      await initPaymentSheet(formData);

      await stripe.Stripe.instance.presentPaymentSheet();

      // Generate order number
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      
      // Clear the cart after successful payment
      final cartManager = Provider.of<CartManagerProvider>(context, listen: false);
      await cartManager.clearCart();

      setState(() {
        _paymentCompleted = true;
        _orderNumber = orderNumber;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment successful! Your cart has been cleared.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
