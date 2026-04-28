import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANOMALY DETECTION LOGS',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitoring viral propagation and unusual sharing spikes across global CDNs',
            style: TextStyle(color: AppTheme.primary.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          // Metric cards row — fixed height
          IntrinsicHeight(
            child: Row(
              children: [
                _metricCard('DAILY SCAN COUNT', '1.4M', LucideIcons.scan, AppTheme.primary),
                const SizedBox(width: 16),
                _metricCard('TOTAL TAKEDOWNS', '4.2K', LucideIcons.shieldCheck, AppTheme.success),
                const SizedBox(width: 16),
                _metricCard('ACTIVE RE-UPLOADS', '892', LucideIcons.refreshCcw, Colors.orange),
                const SizedBox(width: 16),
                _metricCard('AVG RESPONSE TIME', '120ms', LucideIcons.zap, AppTheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Main content — takes remaining space
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildMainChart(context),
                        const SizedBox(height: 24),
                        _buildAlertsList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 280,
                    child: _buildRiskSummary(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Global Traffic Anomalies (Last 24h)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('LIVE SPIKE', style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 8),
                      FlSpot(4, 5), FlSpot(5, 12), FlSpot(6, 4), FlSpot(7, 3),
                    ],
                    isCurved: true,
                    color: AppTheme.error,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AppTheme.error.withOpacity(0.08)),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2), FlSpot(1, 2.5), FlSpot(2, 2), FlSpot(3, 2.2),
                      FlSpot(4, 2.1), FlSpot(5, 2.4), FlSpot(6, 2.3), FlSpot(7, 2.2),
                    ],
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = [
      ('Asset #445 is being shared 500% more than usual — Potential Viral Leak', AppTheme.error),
      ('Unusual traffic from known piracy IP block 192.x.x.x', Colors.orange),
      ('New 97% match found on private tracker — NBA Finals', AppTheme.error),
      ('Telegram channel "sports_leaks" surged +300% in 10 minutes', Colors.orange),
      ('New high-confidence match on Discord CDN link', AppTheme.primary),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Critical Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${alerts.length} ACTIVE', style: const TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map((a) => _alertItem(a.$1, a.$2)),
        ],
      ),
    );
  }

  Widget _alertItem(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildRiskSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Risk Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _riskMetric('CURRENT THREAT LEVEL', 'HIGH', AppTheme.error),
          const Divider(height: 32, color: Colors.white10),
          _riskMetric('ACTIVE PIRACY NODES', '12', Colors.orange),
          const Divider(height: 32, color: Colors.white10),
          _riskMetric('PROTECTION COVERAGE', '94%', AppTheme.success),
          const Divider(height: 32, color: Colors.white10),
          _riskMetric('ASSETS MONITORED', '38', AppTheme.primary),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.shieldAlert, size: 18),
              label: const Text('ENHANCE SECURITY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error.withOpacity(0.1),
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
