import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../models/service_lead.dart';

class ProviderLeadsScreen extends StatefulWidget {
  const ProviderLeadsScreen({super.key});

  @override
  State<ProviderLeadsScreen> createState() => _ProviderLeadsScreenState();
}

class _ProviderLeadsScreenState extends State<ProviderLeadsScreen> {
  final ApiService _apiService = ApiService();
  List<LeadAssignment> _leads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() => _isLoading = true);
    final leads = await _apiService.getProviderLeads();
    if (mounted) {
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String assignmentId, String status) async {
    final success = await _apiService.updateLeadStatus(assignmentId, status);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lead status updated to $status')));
      _fetchLeads();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update lead status. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Requests'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _leads.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchLeads,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _leads.length,
                itemBuilder: (context, index) {
                  final lead = _leads[index];
                  return _buildLeadCard(lead);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No New Requests',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You will receive incoming user requests here.',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadAssignment lead) {
    final isPending = lead.status == 'pending';
    final isAccepted = lead.status == 'accepted';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lead.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(lead.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().add_jm().format(lead.createdAt.toLocal()),
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Customer Location Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: const Text(
                'New Auto-Assigned Lead. Accept to see full details.',
                style: TextStyle(fontSize: 14, color: AppColors.darkText),
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(lead.id, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('DECLINE'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(lead.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('ACCEPT LEAD'),
                    ),
                  ),
                ],
              ),
            ] else if (isAccepted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Chat functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.featured,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Customer'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }
}
