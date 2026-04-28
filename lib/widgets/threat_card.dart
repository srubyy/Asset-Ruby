import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../models/threat.dart';
import '../services/threat_service.dart';
import 'takedown_dialog.dart';

class ThreatCard extends StatelessWidget {
  final Threat threat;
  const ThreatCard({super.key, required this.threat});

  @override
  Widget build(BuildContext context) {
    final isCritical = threat.confidence > 0.94;
    final isHigh = threat.confidence > 0.85;
    final isTakedownSent = threat.status == 'takedown_sent';
    final statusColor = isCritical
        ? AppTheme.error
        : isHigh
            ? Colors.orange
            : AppTheme.success;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isTakedownSent ? Colors.white.withOpacity(0.03) : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTakedownSent
              ? Colors.white.withOpacity(0.05)
              : isCritical
                  ? AppTheme.error.withOpacity(0.4)
                  : Colors.white10,
          width: isCritical && !isTakedownSent ? 2 : 1,
        ),
        boxShadow: [
          if (isCritical && !isTakedownSent)
            BoxShadow(
              color: AppTheme.error.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: -5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (isCritical && !isTakedownSent)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                  ),
                  child: const Text('CRITICAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            if (isTakedownSent)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                    border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                  ),
                  child: const Text('TAKEDOWN SENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _buildAssetThumbnail(),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                threat.assetName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isTakedownSent ? Colors.white38 : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildPlatformBadge(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.link, size: 12, color: AppTheme.primary.withOpacity(0.7)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    threat.link,
                                    style: TextStyle(color: AppTheme.primary.withOpacity(0.8), fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildConfidenceBar(statusColor, isTakedownSent),
                        const SizedBox(height: 8),
                        Text(
                          _timeAgo(threat.detectedAt),
                          style: const TextStyle(color: Colors.white24, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  _buildActionPanel(context, statusColor, isTakedownSent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetThumbnail() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: Colors.black45),
            Icon(LucideIcons.playCircle, color: Colors.white.withOpacity(0.3), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformBadge() {
    IconData icon;
    switch (threat.platform.toLowerCase()) {
      case 'twitter (x)': icon = LucideIcons.twitter; break;
      case 'telegram':    icon = LucideIcons.send; break;
      case 'reddit':      icon = LucideIcons.messageSquare; break;
      case 'discord':     icon = LucideIcons.messagesSquare; break;
      default:            icon = LucideIcons.globe;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Icon(icon, size: 11, color: Colors.white54),
        const SizedBox(width: 5),
        Text(threat.platform.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54)),
      ]),
    );
  }

  Widget _buildConfidenceBar(Color color, bool muted) {
    final c = muted ? Colors.white24 : color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MATCH CONFIDENCE', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text('${(threat.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: threat.confidence,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: c,
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(BuildContext context, Color color, bool isTakedownSent) {
    if (isTakedownSent) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.checkCircle, color: AppTheme.success, size: 28),
          const SizedBox(height: 8),
          const Text('SENT', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => threatService.removeThreat(threat.id),
            child: const Text('DISMISS', style: TextStyle(color: Colors.white24, fontSize: 11)),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final sent = await showDialog<bool>(
              context: context,
              builder: (ctx) => TakedownDialog(threat: threat),
            );
            if (sent == true) {
              threatService.markTakedownSent(threat.id);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(children: [
            Icon(LucideIcons.shieldAlert, size: 16),
            const SizedBox(width: 8),
            const Text('TAKEDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => threatService.removeThreat(threat.id),
          child: const Text('IGNORE', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
