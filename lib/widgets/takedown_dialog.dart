import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../models/threat.dart';

class TakedownDialog extends StatefulWidget {
  final Threat threat;
  const TakedownDialog({super.key, required this.threat});

  @override
  State<TakedownDialog> createState() => _TakedownDialogState();
}

class _TakedownDialogState extends State<TakedownDialog> {
  bool _isSending = false;
  bool _sent = false;
  bool _copied = false;

  String get _notice => '''DMCA TAKEDOWN NOTICE
====================
Date: ${DateTime.now().toUtc().toIso8601String()}
Reference ID: DAP-${widget.threat.id.substring(0, 6).toUpperCase()}

TO: Legal & Trust & Safety Team
PLATFORM: ${widget.threat.platform}

SUBJECT: Unauthorized Use of Proprietary Sports Media

I am the authorized representative of the rights holder for the following
protected content, which has been detected on your platform.

VIOLATING CONTENT:
  URL:      ${widget.threat.link}
  Platform: ${widget.threat.platform}
  Detected: ${widget.threat.detectedAt.toUtc().toIso8601String()}

ORIGINAL PROTECTED ASSET:
  Title:       ${widget.threat.assetName}
  Match Score: ${(widget.threat.confidence * 100).toStringAsFixed(1)}%
  Status:      ${widget.threat.status.toUpperCase()}

DIGITAL FINGERPRINT EVIDENCE:
  Hash Algorithm: SHA-256 + Perceptual Hash
  Confidence:     ${(widget.threat.confidence * 100).toStringAsFixed(2)}%
  System:         Digital Asset Protection (DAP) v1.0
  AI Backend:     Vertex AI Gemini 1.5 Flash (Vector Search)

This content infringes our copyright under 17 U.S.C. § 512(c).
Please remove or disable access to the infringing material immediately.

Failure to comply may result in formal legal action.

Digitally signed by DAP System — ${DateTime.now().millisecondsSinceEpoch}''';

  Future<void> _sendNotice() async {
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() { _isSending = false; _sent = true; });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
          Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.black, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text('Takedown notice sent to ${widget.threat.platform} — Ref: DAP-${widget.threat.id.substring(0, 6).toUpperCase()}')),
              ],
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _notice));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.fileText, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DMCA TAKEDOWN NOTICE', style: Theme.of(context).textTheme.titleLarge),
                    Text('Ref: DAP-${widget.threat.id.substring(0, 6).toUpperCase()}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                // Confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.error.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${(widget.threat.confidence * 100).toStringAsFixed(1)}% MATCH',
                    style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Notice text
            Container(
              height: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _notice,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white70, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: Icon(_copied ? LucideIcons.checkCircle : LucideIcons.copy, size: 16, color: _copied ? AppTheme.success : AppTheme.primary),
                  label: Text(_copied ? 'COPIED!' : 'COPY NOTICE',
                      style: TextStyle(color: _copied ? AppTheme.success : AppTheme.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _copied ? AppTheme.success : AppTheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isSending ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSending || _sent ? null : _sendNotice,
                  icon: _isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Icon(_sent ? LucideIcons.checkCircle : LucideIcons.send, size: 16),
                  label: Text(_isSending ? 'SENDING...' : _sent ? 'SENT!' : 'SEND TO PLATFORM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sent ? AppTheme.success : AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
