import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../models/threat.dart';

class GeoMapScreen extends StatefulWidget {
  const GeoMapScreen({super.key});

  @override
  State<GeoMapScreen> createState() => _GeoMapScreenState();
}

class _GeoMapScreenState extends State<GeoMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final Random _rng = Random();
  Threat? _selectedThreat;

  // Simulated piracy hotspots with geo coordinates
  final List<_PiracyNode> _nodes = [
    _PiracyNode('NBA Finals Q4', LatLng(37.77, -122.42), 'Twitter (X)', 0.98, 'critical', 'San Francisco'),
    _PiracyNode('UFC 300 Main', LatLng(51.50, -0.12), 'Telegram', 0.92, 'high', 'London'),
    _PiracyNode('Champions League', LatLng(48.85, 2.35), 'Local Forum', 0.87, 'high', 'Paris'),
    _PiracyNode('NBA Finals Q4', LatLng(1.35, 103.82), 'IPTV Stream', 0.95, 'critical', 'Singapore'),
    _PiracyNode('Formula 1 GP', LatLng(35.68, 139.69), 'Discord', 0.89, 'high', 'Tokyo'),
    _PiracyNode('Wimbledon Final', LatLng(-23.55, -46.63), 'Telegram', 0.94, 'critical', 'São Paulo'),
    _PiracyNode('Super Bowl Ads', LatLng(55.75, 37.61), 'Tor Network', 0.91, 'high', 'Moscow'),
    _PiracyNode('IPL Final', LatLng(19.07, 72.87), 'Private Tracker', 0.96, 'critical', 'Mumbai'),
    _PiracyNode('UFC 300 Main', LatLng(25.20, 55.27), 'Telegram', 0.88, 'high', 'Dubai'),
    _PiracyNode('NBA Finals Q4', LatLng(-33.86, 151.20), 'Reddit', 0.83, 'medium', 'Sydney'),
    _PiracyNode('Champions League', LatLng(40.41, -3.70), 'Forum', 0.86, 'high', 'Madrid'),
    _PiracyNode('Formula 1 GP', LatLng(52.52, 13.40), 'Discord', 0.79, 'medium', 'Berlin'),
  ];

  // Simulated propagation paths (origin -> spread)
  final List<_PropagationPath> _paths = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _buildPaths();
  }

  void _buildPaths() {
    // Mumbai -> London -> Paris -> Moscow (insider leak chain)
    _paths.add(_PropagationPath(
      LatLng(19.07, 72.87),
      LatLng(51.50, -0.12),
      AppTheme.error,
    ));
    _paths.add(_PropagationPath(
      LatLng(51.50, -0.12),
      LatLng(48.85, 2.35),
      AppTheme.error,
    ));
    _paths.add(_PropagationPath(
      LatLng(48.85, 2.35),
      LatLng(55.75, 37.61),
      Colors.orange,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIVE GEO-PROPAGATION MAP',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Real-time global piracy spread tracking — ${_nodes.length} active nodes detected',
                          style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _legendDot(AppTheme.error, 'Critical'),
                        const SizedBox(width: 16),
                        _legendDot(Colors.orange, 'High'),
                        const SizedBox(width: 16),
                        _legendDot(AppTheme.primary, 'Medium'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(20, 0),
                        initialZoom: 2.0,
                        maxZoom: 8,
                        minZoom: 1.5,
                        backgroundColor: const Color(0xFF0A0A0A),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.dap.app',
                        ),
                        PolylineLayer(
                          polylines: _paths
                              .map<Polyline>((p) => Polyline(
                                    points: [p.from, p.to],
                                    color: p.color.withOpacity(0.5),
                                    strokeWidth: 2.0,
                                  ))
                              .toList(),
                        ),
                        MarkerLayer(
                          markers: _nodes.map((node) {
                            final color = node.severity == 'critical'
                                ? AppTheme.error
                                : node.severity == 'high'
                                    ? Colors.orange
                                    : AppTheme.primary;
                            return Marker(
                              point: node.position,
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedThreat = Threat(
                                      id: node.assetName,
                                      assetId: node.assetName,
                                      assetName: node.assetName,
                                      platform: node.platform,
                                      link: 'https://geo-node/${node.city}',
                                      confidence: node.confidence,
                                      status: 'flagged',
                                      detectedAt: DateTime.now(),
                                    )),
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 30 + 10 * _pulseController.value,
                                          height: 30 + 10 * _pulseController.value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color.withOpacity(
                                                0.15 * (1 - _pulseController.value)),
                                          ),
                                        ),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Overlay stats
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_nodes.where((n) => n.severity == 'critical').length} Critical Nodes',
                                style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${_nodes.where((n) => n.severity == 'high').length} High Risk Nodes',
                                style: const TextStyle(color: Colors.orange, fontSize: 12)),
                            Text('Propagation paths: ${_paths.length}',
                                style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Side panel
        Container(
          width: 300,
          color: AppTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('DETECTED NODES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _nodes.length,
                  itemBuilder: (context, i) {
                    final node = _nodes[i];
                    final color = node.severity == 'critical' ? AppTheme.error : node.severity == 'high' ? Colors.orange : AppTheme.primary;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(node.city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(node.assetName, style: const TextStyle(color: Colors.white54, fontSize: 11), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Text('${(node.confidence * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _PiracyNode {
  final String assetName;
  final LatLng position;
  final String platform;
  final double confidence;
  final String severity;
  final String city;
  _PiracyNode(this.assetName, this.position, this.platform, this.confidence, this.severity, this.city);
}

class _PropagationPath {
  final LatLng from;
  final LatLng to;
  final Color color;
  _PropagationPath(this.from, this.to, this.color);
}
