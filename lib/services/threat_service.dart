import 'dart:async';
import 'dart:math';
import '../models/threat.dart';

class ThreatService {
  static final ThreatService _instance = ThreatService._internal();
  factory ThreatService() => _instance;
  ThreatService._internal() {
    _generateInitialData();
    Timer.periodic(const Duration(seconds: 12), (_) => _addNewMockThreat());
  }

  final _threatController = StreamController<List<Threat>>.broadcast();
  final List<Threat> _currentThreats = [];
  final Random _random = Random();

  Stream<List<Threat>> get threatsStream => _threatController.stream;
  List<Threat> get currentThreats => List.unmodifiable(_currentThreats);

  void removeThreat(String id) {
    _currentThreats.removeWhere((t) => t.id == id);
    _threatController.add(List.from(_currentThreats));
  }

  void markTakedownSent(String id) {
    final idx = _currentThreats.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = _currentThreats[idx];
      _currentThreats[idx] = Threat(
        id: t.id, assetId: t.assetId, assetName: t.assetName,
        platform: t.platform, link: t.link, confidence: t.confidence,
        status: 'takedown_sent', detectedAt: t.detectedAt,
      );
      _threatController.add(List.from(_currentThreats));
    }
  }

  void _generateInitialData() {
    final assets = [
      'NBA Finals Q4 Highlights', 'UFC 300 Main Event', 'Champions League Final',
      'Super Bowl LVIII Highlights', 'Formula 1 Monaco GP', 'Wimbledon Men\'s Final',
      'IPL 2024 Final', 'Olympics 100m Sprint Final',
    ];
    final platforms = ['Twitter (X)', 'Telegram', 'Reddit', 'Discord', 'IPTV Stream', 'Tor Network', 'Local Forum'];

    for (int i = 0; i < 20; i++) {
      final asset = assets[_random.nextInt(assets.length)];
      final platform = platforms[_random.nextInt(platforms.length)];
      final confidence = 0.76 + _random.nextDouble() * 0.23;
      _currentThreats.add(Threat(
        id: 'init_$i',
        assetId: 'a${_random.nextInt(8)}',
        assetName: asset,
        platform: platform,
        link: _link(platform),
        confidence: confidence,
        status: confidence > 0.92 ? 'flagged' : 'pending',
        detectedAt: DateTime.now().subtract(Duration(minutes: i * 4 + _random.nextInt(10))),
      ));
    }
    _threatController.add(List.from(_currentThreats));
  }

  String _link(String platform) {
    switch (platform) {
      case 'Twitter (X)': return 'https://x.com/sports_leaks/status/${_random.nextInt(9999999)}';
      case 'Telegram':    return 'https://t.me/pirate_streams/${_random.nextInt(999)}';
      case 'Reddit':      return 'https://reddit.com/r/sports_streams/comments/${_random.nextInt(9999)}';
      case 'Discord':     return 'https://cdn.discordapp.com/attachments/${_random.nextInt(9999999)}';
      default:            return 'https://piracy-host-${_random.nextInt(99)}.biz/file/${_random.nextInt(9999)}';
    }
  }

  void _addNewMockThreat() {
    final assets = ['NBA Finals Q4 Highlights', 'UFC 300 Main Event', 'Champions League Final'];
    final platforms = ['Twitter (X)', 'Telegram', 'IPTV Stream'];
    final asset = assets[_random.nextInt(assets.length)];
    final platform = platforms[_random.nextInt(platforms.length)];
    final confidence = 0.88 + _random.nextDouble() * 0.11;

    _currentThreats.insert(0, Threat(
      id: 'live_${DateTime.now().millisecondsSinceEpoch}',
      assetId: 'a1',
      assetName: asset,
      platform: platform,
      link: _link(platform),
      confidence: confidence,
      status: 'flagged',
      detectedAt: DateTime.now(),
    ));
    if (_currentThreats.length > 50) _currentThreats.removeLast();
    _threatController.add(List.from(_currentThreats));
  }

  void dispose() => _threatController.close();
}

final threatService = ThreatService();
