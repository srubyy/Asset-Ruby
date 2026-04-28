import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../models/threat.dart';
import '../widgets/threat_card.dart';
import '../services/threat_service.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ValueNotifier<String> _activeFilter = ValueNotifier<String>('All Platforms');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          const SizedBox(height: 32),
          _buildFilterBar(),
          const SizedBox(height: 24),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _activeFilter,
              builder: (context, activeFilter, child) {
                return StreamBuilder<List<Threat>>(
                  stream: threatService.threatsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var threats = snapshot.data!;
                    
                    // Apply mock filtering
                    if (activeFilter == 'High Confidence') {
                      threats = threats.where((t) => t.confidence > 0.95).toList();
                    } else if (activeFilter == 'Active Leaks') {
                      threats = threats.where((t) => t.status == 'flagged').toList();
                    }

                    if (threats.isEmpty) {
                      return const Center(
                        child: Text('No threats found for this filter.', style: TextStyle(color: Colors.white38)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: threats.length,
                      itemBuilder: (context, index) {
                        return ThreatCard(threat: threats[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'THREAT MONITOR',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.error.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text('SYSTEM AT RISK', style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing 452 concurrent streams across 14 platforms',
              style: TextStyle(color: AppTheme.primary.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
        _buildStats(context),
      ],
    );
  }

  Widget _buildFilterBar() {
    return ValueListenableBuilder<String>(
      valueListenable: _activeFilter,
      builder: (context, activeFilter, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, size: 18, color: Colors.white38),
                    const SizedBox(width: 12),
                    const Text('Search threats by asset name, URL, or platform...', style: TextStyle(color: Colors.white24)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            _filterChip('All Platforms', activeFilter == 'All Platforms'),
            const SizedBox(width: 8),
            _filterChip('High Confidence', activeFilter == 'High Confidence'),
            const SizedBox(width: 8),
            _filterChip('Active Leaks', activeFilter == 'Active Leaks'),
          ],
        );
      },
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _activeFilter.value = label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.primary : Colors.white10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _statTile('TOTAL FLAGGED', '128', LucideIcons.flag),
        const SizedBox(width: 16),
        _statTile('AVG CONFIDENCE', '92%', LucideIcons.target),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
