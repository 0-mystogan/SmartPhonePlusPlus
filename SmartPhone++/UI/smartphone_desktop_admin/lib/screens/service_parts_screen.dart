import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/service_part.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/providers/service_part_provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';

class ServicePartsScreen extends StatefulWidget {
  final Service service;
  const ServicePartsScreen({super.key, required this.service});

  @override
  State<ServicePartsScreen> createState() => _ServicePartsScreenState();
}

class _ServicePartsScreenState extends State<ServicePartsScreen> {
  late ServicePartProvider servicePartProvider;
  late PartProvider partProvider;
  SearchResult<ServicePart>? _serviceParts;
  List<Part> _parts = [];
  Part? _selectedPart;
  final TextEditingController _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      servicePartProvider = context.read<ServicePartProvider>();
      partProvider = context.read<PartProvider>();
      await _loadParts();
      await _loadServiceParts();
    });
  }

  Future<void> _loadParts() async {
    final result = await partProvider.get(filter: {"page": 0, "pageSize": 100, "includeTotalCount": true});
    setState(() {
      _parts = result.items ?? [];
    });
  }

  Future<void> _loadServiceParts() async {
    final result = await servicePartProvider.getForService(widget.service.id);
    setState(() {
      _serviceParts = result;
    });
  }

  Future<void> _addPart() async {
    if (_selectedPart == null) return;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final unitPrice = _selectedPart!.price;
    final ok = await servicePartProvider.addPartToService(
      serviceId: widget.service.id,
      partId: _selectedPart!.id,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    if (ok) {
      await _loadServiceParts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Part added to service')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Service Parts - ${widget.service.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Part>(
                    value: _selectedPart,
                    decoration: InputDecoration(
                      labelText: 'Part',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _parts.map((p) => DropdownMenuItem<Part>(value: p, child: Text(p.name))).toList(),
                    onChanged: (val) => setState(() => _selectedPart = val),
                    isExpanded: true,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _quantityController,
                    decoration: customTextFieldDecoration('Qty'),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _addPart(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _addPart, child: Text('Add')),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _serviceParts?.items?.length ?? 0,
                itemBuilder: (_, i) {
                  final sp = _serviceParts!.items![i];
                  return ListTile(
                    title: Text(sp.partName ?? 'Part #${sp.partId}'),
                    subtitle: Text('Qty: ${sp.quantity}  •  Unit: ${sp.unitPrice.toStringAsFixed(2)}  •  Total: ${sp.totalPrice.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await servicePartProvider.removePartFromService(serviceId: widget.service.id, partId: sp.partId);
                        if (ok) {
                          await _loadServiceParts();
                        }
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


