import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/service_profile.dart';
import '../../providers/services_provider.dart';

class ServiceBookingScreen extends StatefulWidget {
  final ServiceProfile profile;

  const ServiceBookingScreen({super.key, required this.profile});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  bool _isBooking = false;

  void _bookService() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a service address')),
      );
      return;
    }

    setState(() => _isBooking = true);

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final Map<String, dynamic> bookingData = {
      'service_profile_id': widget.profile.id,
      'scheduled_date': scheduledDateTime.toIso8601String(),
      'service_address': _addressController.text.trim(),
      'instructions': _instructionsController.text.trim(),
    };

    final provider = context.read<ServicesProvider>();
    final success = await provider.createBooking(bookingData);

    setState(() => _isBooking = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Booking requested successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to the list
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to book service')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Service', style: TextStyle(color: AppColors.darkText)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Info
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.lightGrey),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightGrey,
                  backgroundImage: widget.profile.images.isNotEmpty
                      ? NetworkImage(widget.profile.images.first)
                      : null,
                  child: widget.profile.images.isEmpty
                      ? const Icon(Icons.person, color: AppColors.grey)
                      : null,
                ),
                title: Text(widget.profile.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('₹\${widget.profile.basePrice} / \${widget.profile.priceType}'),
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time Selection
            const Text('When do you need the service?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                                : 'Select Date',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => _selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select Time',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Address
            const Text('Service Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Enter full address...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            const Text('Special Instructions (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any specific requirements for the provider?',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _bookService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Booking',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
