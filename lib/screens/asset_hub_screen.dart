import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';

class AssetHubScreen extends StatefulWidget {
  const AssetHubScreen({super.key});

  @override
  State<AssetHubScreen> createState() => _AssetHubScreenState();
}

class _AssetHubScreenState extends State<AssetHubScreen> with TickerProviderStateMixin {
  int _uploadStage = 0;
  String? _fileName;
  String? _generatedHash;
  final List<_AiLogLine> _aiLog = [];

  final List<_GoldenAsset> _goldenAssets = [
    _GoldenAsset('NBA Finals Q4', 'A92B3F7D...12', 'Video', '2.4 GB'),
    _GoldenAsset('UFC 300 Main Event', 'F83C9A2E...99', 'Video', '3.1 GB'),
    _GoldenAsset('CL Final 2024', 'D11E7B4F...44', 'Video', '4.0 GB'),
    _GoldenAsset('Monaco GP FP1', 'B22F5C1A...77', 'Video', '1.8 GB'),
    _GoldenAsset('Wimbledon Day 1', 'C99A3D8E...11', 'Video', '2.2 GB'),
    _GoldenAsset('Super Bowl Ads', 'E55D6B9C...88', 'Image Pack', '890 MB'),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'jpg', 'png'],
    );
    if (result == null) return;
    final name = result.files.single.name;
    final rng = Random();

    setState(() {
      _fileName = name;
      _uploadStage = 1;
      _aiLog.clear();
    });

    // Stage 1: Upload
    _addLog('INFO', 'File received: $name → Firebase Storage upload initiated');
    await Future.delayed(const Duration(milliseconds: 700));
    _addLog('INFO', 'Stored at: gs://dap-bucket/official_assets/$name');

    // Stage 2: Hashing
    setState(() => _uploadStage = 2);
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('HASH', 'Computing SHA-256 digest...');
    await Future.delayed(const Duration(milliseconds: 600));
    final hash = List.generate(8, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    setState(() => _generatedHash = hash);
    _addLog('HASH', 'Perceptual hash (pHash): $hash');

    // Stage 3: Vertex AI embedding
    setState(() => _uploadStage = 3);
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('VERTEX', 'Calling Vertex AI → model: multimodalembedding@001');
    await Future.delayed(const Duration(milliseconds: 800));
    _addLog('VERTEX', 'Gemini 1.5 Flash → scene & object feature extraction');
    await Future.delayed(const Duration(milliseconds: 600));
    _addLog('VERTEX', 'Embedding dimensions: 1408-d vector generated');

    // Stage 4: Index
    setState(() => _uploadStage = 4);
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('INDEX', 'Writing embedding → Vertex AI Vector Search index');
    await Future.delayed(const Duration(milliseconds: 700));
    _addLog('INDEX', 'Firestore document created: assets/$hash');
    _addLog('SUCCESS', 'Asset fingerprinted & indexed. Scout Engine now monitoring.');

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _goldenAssets.insert(0, _GoldenAsset(
          name.replaceAll(RegExp(r'\.[^.]+$'), ''),
          '${hash.substring(0, 8)}...NEW',
          name.endsWith('.mp4') || name.endsWith('.mov') ? 'Video' : 'Image',
          'Just uploaded',
          isNew: true,
        ));
        _uploadStage = 0;
        _fileName = null;
        _generatedHash = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(LucideIcons.checkCircle, color: Colors.black, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text('Asset fingerprinted via Vertex AI. Hash: $hash')),
        ]),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  void _addLog(String level, String msg) {
    if (mounted) {
      setState(() {
        _aiLog.add(_AiLogLine(level, msg, DateTime.now()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ASSET INGESTION HUB', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    'Upload media → Vertex AI fingerprints it → Scout Engine monitors all platforms',
                    style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
              Row(children: [
                _statBadge('${_goldenAssets.length}', 'Assets Protected', AppTheme.success),
                const SizedBox(width: 12),
                _statBadge('multimodalembedding@001', 'AI Model', AppTheme.secondary),
              ]),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: upload zone
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      MouseRegion(
                        cursor: _uploadStage == 0 ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: _uploadStage == 0 ? _pickFile : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 180,
                            decoration: BoxDecoration(
                              color: _uploadStage > 0 ? AppTheme.primary.withOpacity(0.04) : AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _uploadStage > 0 ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: _uploadStage == 0
                                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Icon(LucideIcons.uploadCloud, size: 44, color: AppTheme.primary),
                                    const SizedBox(height: 14),
                                    const Text('Click to Upload Official Media', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    const Text('MP4 · MOV · JPG · PNG', style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ])
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Icon(LucideIcons.fileVideo, size: 18, color: AppTheme.primary),
                                          const SizedBox(width: 10),
                                          Text(_fileName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          if (_generatedHash != null) ...[
                                            const Spacer(),
                                            Text('HASH: $_generatedHash', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppTheme.primary)),
                                          ]
                                        ]),
                                        const SizedBox(height: 20),
                                        _buildPipeline(),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // AI Log terminal
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Text('VERTEX AI PIPELINE LOG', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ]),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _aiLog.isEmpty
                                    ? const Center(child: Text('Upload an asset to see the AI pipeline in action...', style: TextStyle(color: Colors.white24, fontSize: 12)))
                                    : ListView.builder(
                                        itemCount: _aiLog.length,
                                        itemBuilder: (_, i) {
                                          final log = _aiLog[i];
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
                                                children: [
                                                  TextSpan(
                                                    text: '[${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}:${log.time.second.toString().padLeft(2, '0')}] ',
                                                    style: const TextStyle(color: Colors.white38),
                                                  ),
                                                  TextSpan(
                                                    text: '[${log.level}] ',
                                                    style: TextStyle(color: _logColor(log.level), fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(text: log.msg, style: const TextStyle(color: Colors.white70)),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right: info panel
                SizedBox(
                  width: 260,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _infoPanel(),
                        const SizedBox(height: 16),
                        _techStackPanel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROTECTED GOLDEN ASSETS', style: Theme.of(context).textTheme.titleLarge),
              Text('${_goldenAssets.length} assets monitored', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(height: 180, child: _buildAssetGrid()),
        ],
      ),
    );
  }

  Widget _buildPipeline() {
    final stages = ['Uploading', 'Hashing', 'AI Embed', 'Indexed'];
    return Row(
      children: List.generate(stages.length, (i) {
        final done = _uploadStage > i + 1;
        final active = _uploadStage == i + 1;
        final color = done ? AppTheme.success : active ? AppTheme.primary : Colors.white24;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
                      child: Center(
                        child: active
                            ? const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                            : done
                                ? const Icon(LucideIcons.check, size: 13, color: AppTheme.success)
                                : Text('${i + 1}', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(stages[i], style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (i < stages.length - 1)
                Container(height: 1, width: 16, color: Colors.white10),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI PIPELINE', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          _step('1', 'Cloud Storage', 'Asset uploaded to Firebase Storage', AppTheme.primary),
          _step('2', 'SHA-256 + pHash', 'Cryptographic & perceptual fingerprint', Colors.orange),
          _step('3', 'Vertex AI Embed', 'multimodalembedding@001 generates 1408-d vector', AppTheme.secondary),
          _step('4', 'Vector Search', 'Indexed in Vertex AI Vector Search DB', AppTheme.success),
        ],
      ),
    );
  }

  Widget _techStackPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(LucideIcons.cpu, size: 14, color: AppTheme.secondary),
            const SizedBox(width: 8),
            const Text('GOOGLE CLOUD AI', style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ]),
          const SizedBox(height: 14),
          _techItem('Vertex AI', 'multimodalembedding@001'),
          _techItem('Gemini 1.5 Flash', 'Scene extraction & analysis'),
          _techItem('Vector Search', 'ANN similarity matching'),
          _techItem('Cloud Vision API', 'Watermark & crop detection'),
          _techItem('Firebase Storage', 'Asset CDN & storage'),
        ],
      ),
    );
  }

  Widget _step(String num, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 20, height: 20,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.4))),
            child: Center(child: Text(num, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _techItem(String name, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle)),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
              Text(detail, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ]),
    );
  }

  Widget _buildAssetGrid() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _goldenAssets.length,
      itemBuilder: (context, index) {
        final asset = _goldenAssets[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: asset.isNew ? AppTheme.success.withOpacity(0.5) : Colors.white10, width: asset.isNew ? 2 : 1),
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/seed/${asset.name}/300/200'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)]),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (asset.isNew)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.success.withOpacity(0.5))),
                    child: const Text('NEW', style: TextStyle(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('HASH: ${asset.hash}', style: const TextStyle(fontSize: 9, color: AppTheme.primary, fontFamily: 'monospace')),
                const SizedBox(height: 3),
                Text(asset.size, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _logColor(String level) {
    switch (level) {
      case 'VERTEX': return AppTheme.secondary;
      case 'SUCCESS': return AppTheme.success;
      case 'HASH': return Colors.orange;
      case 'INDEX': return AppTheme.primary;
      default: return Colors.white54;
    }
  }
}

class _AiLogLine {
  final String level, msg;
  final DateTime time;
  _AiLogLine(this.level, this.msg, this.time);
}

class _GoldenAsset {
  final String name, hash, type, size;
  final bool isNew;
  _GoldenAsset(this.name, this.hash, this.type, this.size, {this.isNew = false});
}
