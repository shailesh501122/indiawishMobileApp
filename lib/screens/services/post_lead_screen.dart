import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../models/service_category.dart';

class PostLeadScreen extends StatefulWidget {
  final ServiceCategory category;

  const PostLeadScreen({super.key, required this.category});

  @override
  State<PostLeadScreen> createState() => _PostLeadScreenState();
}

class _PostLeadScreenState extends State<PostLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  void _submitLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final api = ApiService();
    final lead = await api.createServiceLead({
      'category_id': widget.category.id,
      'location': _locationController.text.trim(),
      'description': _descController.text.trim(),
    });

    setState(() => _isLoading = false);

    if (lead != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request posted! We will find the best providers for you.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post request. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Request ${widget.category.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Let top professionals come to you!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe what you need, and we will automatically notify the best available professionals in your area.',
                style: TextStyle(color: AppColors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),

              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g. Andheri West, Mumbai',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Location required' : null,
              ),

              const SizedBox(height: 24),

              const Text(
                'Describe your need',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'e.g. I need full house deep cleaning this Sunday...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Description required' : null,
              ),

              const SizedBox(height: 48),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'POST REQUEST',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
