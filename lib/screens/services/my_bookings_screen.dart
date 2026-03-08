import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/services_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Service Bookings', style: TextStyle(color: AppColors.darkText)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.myBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: AppColors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookings found',
                    style: TextStyle(fontSize: 16, color: AppColors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchMyBookings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.myBookings.length,
              itemBuilder: (context, index) {
                final booking = provider.myBookings[index];
                final dateStr = DateFormat('MMM d, yyyy - h:mm a').format(booking.scheduledDate);
                
                Color statusColor = Colors.grey;
                if (booking.status == 'pending') statusColor = Colors.orange;
                if (booking.status == 'accepted') statusColor = Colors.blue;
                if (booking.status == 'completed') statusColor = Colors.green;
                if (booking.status == 'cancelled') statusColor = Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking #\${booking.id.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                            const SizedBox(width: 8),
                            Text(dateStr, style: const TextStyle(color: AppColors.darkText)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(booking.serviceAddress, style: const TextStyle(color: AppColors.darkText))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quoted Price', style: TextStyle(color: AppColors.grey)),
                            Text(
                              '₹\${booking.quotedPrice.toStringAsFixed(0)} / \${booking.priceType}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
