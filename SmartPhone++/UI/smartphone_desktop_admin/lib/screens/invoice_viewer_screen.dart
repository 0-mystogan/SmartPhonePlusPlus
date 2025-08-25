import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:smartphone_desktop_admin/providers/auth_provider.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';

class InvoiceViewerScreen extends StatefulWidget {
  const InvoiceViewerScreen({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  File? _pdfFile;

  // Get base URL from environment
  String get baseUrl {
    return const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5130/",
    );
  }

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final uri = Uri.parse('${baseUrl}api/ServiceInvoice/${widget.serviceId}');

      final String username = AuthProvider.username ?? '';
      final String password = AuthProvider.password ?? '';
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final headers = <String, String>{
        'Authorization': basicAuth,
        'Accept': 'application/pdf',
      };

      final response = await http.get(uri, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/invoice_${widget.serviceId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        setState(() {
          _pdfFile = file;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Invoice not found';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load invoice';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load invoice';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(
            tooltip: 'Print',
            icon: const Icon(Icons.print),
            onPressed: _isLoading
                ? null
                : () async {
                    if (_pdfFile == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No invoice to print')),
                      );
                      return;
                    }
                    try {
                      final bytes = await _pdfFile!.readAsBytes();
                      await Printing.layoutPdf(
                        onLayout: (format) async => bytes,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to print invoice'),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _pdfFile != null
          ? SfPdfViewer.file(_pdfFile!)
          : const Center(child: Text('Failed to load invoice')),
    );
  }
}
