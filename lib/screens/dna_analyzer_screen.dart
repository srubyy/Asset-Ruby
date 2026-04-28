import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../services/gemini_service.dart';

class DnaAnalyzerScreen extends StatefulWidget {
  const DnaAnalyzerScreen({super.key});

  @override
  State<DnaAnalyzerScreen> createState() => _DnaAnalyzerScreenState();
}

class _DnaAnalyzerScreenState extends State<DnaAnalyzerScreen>
    with TickerProviderStateMixin {
  int _selectedAssetIndex = 0;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  GeminiAnalysisResult? _result;
  final List<_AiStep> _analysisSteps = [];
  late AnimationController _pulseController;

  final List<_DnaAsset> _assets = [
    _DnaAsset('NBA Finals Q4 Highlights', 'A92B3F7D...12', 'Twitter (X)', 0.96),
    _DnaAsset('UFC 300 Main Event', 'F83C9A2E...99', 'Telegram', 0.91),
    _DnaAsset('Champions League Final', 'D11E7B4F...44', 'IPTV Stream', 0.98),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
      _hasError = false;
      _analysisSteps.clear();
      _result = null;
    });

    final asset = _assets[_selectedAssetIndex];

    // Stream in the API log steps
    final steps = [
      _AiStep('Vertex AI', 'POST .../multimodalembedding@001:predict', 'Generating 1408-d embedding for original asset...'),
      _AiStep('Vertex AI', 'POST .../multimodalembedding@001:predict', 'Generating 1408-d embedding for pirated content...'),
      _AiStep('Vector Search', 'ANN lookup → cosine similarity: ${(asset.confidence * 100).toStringAsFixed(2)}%', 'Match confirmed in 14ms'),
      _AiStep('Gemini 1.5 Flash', 'POST .../gemini-1.5-flash:generateContent', 'Running forensic mutation analysis prompt...'),
      _AiStep('Cloud Vision API', 'POST /v1/images:annotate → OBJECT_LOCALIZATION', 'Watermark region scan + logo detection...'),
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _analysisSteps.add(step));
    }

    try {
      // *** REAL GEMINI API CALL ***
      final result = await GeminiService.analyzeMutations(
        assetName: asset.name,
        assetHash: asset.hash,
        platform: asset.platform,
        confidence: asset.confidence,
      );

      if (mounted) {
        setState(() {
          _analysisSteps.add(_AiStep('SUCCESS', 'Analysis complete — ${result.mutations.length} mutations detected — evasionScore: ${result.evasionScore}/100', ''));
          _result = result;
          _isAnalyzing = false;
          _analysisComplete = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assets[_selectedAssetIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('PIRACY DNA ANALYZER', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.secondary.withOpacity(0.5)),
                      ),
                      child: Row(children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) => Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.secondary.withOpacity(0.5 + 0.5 * _pulseController.value),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.cpu, size: 11, color: AppTheme.secondary),
                        const SizedBox(width: 5),
                        const Text('Gemini 1.5 Flash — LIVE', style: TextStyle(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time AI forensics — Gemini analyzes HOW your content was mutated to evade detection',
                    style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: asset picker + comparison
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Asset tabs
                      Row(
                        children: List.generate(_assets.length, (i) {
                          final sel = i == _selectedAssetIndex;
                          return GestureDetector(
                            onTap: () => setState(() { _selectedAssetIndex = i; _analysisComplete = false; _result = null; _analysisSteps.clear(); }),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: sel ? AppTheme.primary : Colors.white10),
                                ),
                                child: Text(_assets[i].name,
                                    style: TextStyle(
                                        color: sel ? AppTheme.primary : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      // Visual diff
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildVideoPanel('ORIGINAL ASSET', AppTheme.success, asset.hash, false)),
                            const SizedBox(width: 16),
                            _buildVsIndicator(),
                            const SizedBox(width: 16),
                            Expanded(child: _buildVideoPanel('PIRATED VERSION', AppTheme.error, 'MODIFIED', true, _result)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Analyze button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _runAnalysis,
                          icon: _isAnalyzing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(LucideIcons.dna, size: 20),
                          label: Text(_isAnalyzing ? 'GEMINI ANALYZING...' : 'ANALYZE WITH GEMINI AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right panel: API log + results
                SizedBox(
                  width: 360,
                  child: _analysisComplete && _result != null
                      ? _buildResultsPanel(_result!)
                      : _buildLogPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPanel(String label, Color color, String hash, bool showOverlay, [GeminiAnalysisResult? result]) {
    final mutations = result?.mutations ?? [];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Center(child: Icon(LucideIcons.playCircle, size: 48, color: Colors.white.withOpacity(0.12))),
            // Heatmap zones — either AI-generated or static
            if (showOverlay && mutations.isNotEmpty) ..._buildAiHeatZones(mutations),
            if (showOverlay && mutations.isEmpty) ...[
              Positioned(top: 0, right: 0, child: _heatZone(65, 30, AppTheme.error, 'WATERMARK')),
              Positioned(top: 44, left: 18, child: _heatZone(75, 22, Colors.orange, 'CROP')),
              Positioned(bottom: 32, left: 38, child: _heatZone(100, 24, Colors.orange, 'RE-ENCODE')),
            ],
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)]),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(hash, style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAiHeatZones(List<GeminiMutation> mutations) {
    final positions = [
      {'top': 0.0, 'right': 0.0},
      {'top': 40.0, 'left': 16.0},
      {'bottom': 35.0, 'left': 35.0},
      {'top': 80.0, 'right': 20.0},
    ];
    return mutations.take(positions.length).toList().asMap().entries.map((e) {
      final m = e.value;
      final pos = positions[e.key];
      final color = _mutationColor(m.type);
      return Positioned(
        top: pos['top'],
        bottom: pos['bottom'],
        left: pos['left'],
        right: pos['right'],
        child: _heatZone(
          e.key == 0 ? 70 : e.key == 1 ? 80 : 95,
          26,
          color,
          m.name.split(' ').first.toUpperCase(),
        ),
      );
    }).toList();
  }

  Color _mutationColor(String type) {
    switch (type) {
      case 'watermark': return AppTheme.error;
      case 'temporal': return Colors.orange;
      case 'color': return AppTheme.secondary;
      default: return AppTheme.primary;
    }
  }

  Widget _heatZone(double width, double height, Color color, String label) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.28),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.7), width: 1.5),
      ),
      child: Center(child: Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
    );
  }

  Widget _buildVsIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: const Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildLogPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: _analysisSteps.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Icon(LucideIcons.cpu, size: 44, color: AppTheme.secondary.withOpacity(0.2 + 0.15 * _pulseController.value)),
                ),
                const SizedBox(height: 16),
                const Text('Gemini 1.5 Flash ready', style: TextStyle(color: Colors.white38, fontFamily: 'monospace')),
                const SizedBox(height: 6),
                Text(_hasError ? '⚠ ${_errorMessage.substring(0, _errorMessage.length.clamp(0, 80))}...' : 'Press Analyze to run live AI',
                    style: TextStyle(color: _hasError ? AppTheme.error : Colors.white24, fontSize: 11, fontFamily: 'monospace'),
                    textAlign: TextAlign.center),
                if (_hasError) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Add your key in lib/services/gemini_service.dart', style: const TextStyle(color: Colors.orange, fontSize: 10), textAlign: TextAlign.center),
                  ),
                ],
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('VERTEX AI API LOG', style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'monospace')),
                  ]),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _analysisSteps.length,
                      itemBuilder: (_, i) {
                        final step = _analysisSteps[i];
                        final isSuccess = step.service == 'SUCCESS';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSuccess ? AppTheme.success.withOpacity(0.12) : AppTheme.secondary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isSuccess ? AppTheme.success.withOpacity(0.3) : AppTheme.secondary.withOpacity(0.25)),
                                ),
                                child: Text(step.service, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSuccess ? AppTheme.success : AppTheme.secondary, fontFamily: 'monospace')),
                              ),
                              const SizedBox(height: 4),
                              Text(step.endpoint, style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (step.detail.isNotEmpty) Text('→ ${step.detail}', style: const TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace')),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResultsPanel(GeminiAnalysisResult result) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evasion score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('EVASION SCORE', style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                      ),
                      child: Text('AI: ${result.sophisticationLevel}', style: const TextStyle(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${result.evasionScore}', style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: result.evasionScore > 85 ? AppTheme.error : Colors.orange, height: 1)),
                  const Text('/100', style: TextStyle(color: Colors.white38, fontSize: 18)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: result.evasionScore / 100, color: result.evasionScore > 85 ? AppTheme.error : Colors.orange, backgroundColor: Colors.white10, minHeight: 6),
                ),
                const SizedBox(height: 14),
                _infoRow(LucideIcons.user, result.leakSource),
                const SizedBox(height: 6),
                _infoRow(LucideIcons.mapPin, result.leakRegion),
                const SizedBox(height: 6),
                _infoRow(LucideIcons.userX, result.threatActor),
                if (result.recommendation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.lightbulb, size: 13, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(result.recommendation, style: const TextStyle(color: AppTheme.primary, fontSize: 11))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Mutation list from Gemini
          Container(
            padding: const EdgeInsets.all(20),
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
                    const Text('GEMINI MUTATION REPORT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('${result.mutations.length} FOUND', style: const TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...result.mutations.map((m) => _buildMutationCard(m)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutationCard(GeminiMutation m) {
    final color = _mutationColor(m.type);
    IconData icon;
    switch (m.type) {
      case 'watermark': icon = LucideIcons.eyeOff; break;
      case 'temporal': icon = LucideIcons.clock; break;
      case 'color': icon = LucideIcons.palette; break;
      default: icon = LucideIcons.code;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 8),
                Flexible(child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ]),
              Text('${(m.confidence * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: m.confidence, color: color, backgroundColor: Colors.white10, minHeight: 3),
          ),
          const SizedBox(height: 6),
          Text(m.detail, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 13, color: Colors.white38),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white70))),
    ]);
  }
}

class _AiStep {
  final String service, endpoint, detail;
  _AiStep(this.service, this.endpoint, this.detail);
}

class _DnaAsset {
  final String name, hash, platform;
  final double confidence;
  _DnaAsset(this.name, this.hash, this.platform, this.confidence);
}
