import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/part_category.dart';
import 'package:smartphone_desktop_admin/providers/part_category_provider.dart';
import 'package:smartphone_desktop_admin/screens/part_category_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';

class PartCategoryDetailsScreen extends StatefulWidget {
  final PartCategory? partCategory;
  PartCategoryDetailsScreen({super.key, this.partCategory});

  @override
  State<PartCategoryDetailsScreen> createState() =>
      _PartCategoryDetailsScreenState();
}

class _PartCategoryDetailsScreenState extends State<PartCategoryDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  Map<String, dynamic> _initalValue = {};

  late PartCategoryProvider partCategoryProvider;

  bool isLoading = true;
  List<PartCategory> parentCategories = [];
  bool isLoadingParentCategories = true;
  PartCategory? currentPartCategory;

  @override
  void initState() {
    super.initState();
    partCategoryProvider = Provider.of<PartCategoryProvider>(
      context,
      listen: false,
    );
    currentPartCategory = widget.partCategory;

    _initalValue = {
      "name": currentPartCategory?.name,
      "description": currentPartCategory?.description,
      "isActive": currentPartCategory?.isActive ?? true,
      "parentCategoryId": currentPartCategory?.parentCategoryId?.toString(),
    };
    print("currentPartCategory");
    print(_initalValue);

    initFormData();
  }

  initFormData() async {
    // Load parent categories
    await loadParentCategories();

    setState(() {
      isLoading = false;
    });
  }

  loadParentCategories() async {
    try {
      setState(() {
        isLoadingParentCategories = true;
      });

      // Get all part categories to use as parent options
      var result = await partCategoryProvider.get();
      setState(() {
        parentCategories = result.items ?? [];
        isLoadingParentCategories = false;
      });
    } catch (e) {
      print('Error loading parent categories: $e');
      setState(() {
        isLoadingParentCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Part Category Details",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.cancel),
          label: Text("Cancel"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            formKey.currentState?.saveAndValidate();
            if (formKey.currentState?.validate() ?? false) {
              print(formKey.currentState?.value.toString());
              var request = Map.from(formKey.currentState?.value ?? {});

              // Convert parentCategoryId back to int if it's a string
              if (request['parentCategoryId'] != null &&
                  request['parentCategoryId'] is String) {
                request['parentCategoryId'] = int.tryParse(
                  request['parentCategoryId'],
                );
              }

              try {
                if (currentPartCategory == null) {
                  currentPartCategory = await partCategoryProvider.insert(
                    request,
                  );
                } else {
                  currentPartCategory = await partCategoryProvider.update(
                    currentPartCategory!.id,
                    request,
                  );
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PartCategoryListScreen(),
                  ),
                );
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          icon: Icon(Icons.save),
          label: Text("Save"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: _initalValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Part Category',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "Name",
                      prefixIcon: Icons.text_fields,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(r'^[A-Za-z0-9\s\-_]+'),
                        errorText:
                            'Only letters, numbers, spaces, hyphens and underscores allowed',
                      ),
                    ]),
                  ),
                  SizedBox(height: 16),
                  FormBuilderTextField(
                    name: "description",
                    decoration: customTextFieldDecoration(
                      "Description (optional)",
                      prefixIcon: Icons.description,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  FormBuilderDropdown<int>(
                    name: "parentCategoryId",
                    decoration: customTextFieldDecoration(
                      "Parent Category (optional)",
                      prefixIcon: Icons.category,
                    ),
                    items: isLoadingParentCategories
                        ? [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Loading categories..."),
                                ],
                              ),
                            ),
                          ]
                        : [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text("No Parent Category"),
                            ),
                            ...parentCategories.map(
                              (category) => DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            ),
                          ],
                    valueTransformer: (value) => value?.toString(),
                  ),
                  SizedBox(height: 16),
                  FormBuilderCheckbox(
                    name: "isActive",
                    title: Text("Active", style: TextStyle(fontSize: 16)),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 50),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
