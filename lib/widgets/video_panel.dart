import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../theme.dart';

class VideoPanel extends StatefulWidget {
  final String label;
  final Color borderColor;
  final String hashLabel;
  final String videoUrl;
  final bool showOverlay;
  final List<HeatZone> heatZones;

  const VideoPanel({
    super.key,
    required this.label,
    required this.borderColor,
    required this.hashLabel,
    required this.videoUrl,
    this.showOverlay = false,
    this.heatZones = const [],
  });

  @override
  State<VideoPanel> createState() => _VideoPanelState();
}

class _VideoPanelState extends State<VideoPanel> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      _controller.setLooping(true);
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor.withOpacity(0.4), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or fallback
            if (_initialized)
              GestureDetector(
                onTap: () => setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                }),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else if (_error)
              const Center(child: Icon(LucideIcons.videoOff, color: Colors.white24, size: 36))
            else
              const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),

            // Play/pause overlay
            if (_initialized)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  }),
                  child: AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black38,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Icon(LucideIcons.play, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Heatmap zones
            if (widget.showOverlay)
              ...widget.heatZones.map((z) => Positioned(
                    top: z.top,
                    left: z.left,
                    right: z.right,
                    bottom: z.bottom,
                    child: Container(
                      width: z.w,
                      height: z.h,
                      decoration: BoxDecoration(
                        color: z.color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: z.color.withOpacity(0.7), width: 1.5),
                      ),
                      child: Center(
                        child: Text(z.label,
                            style: TextStyle(color: z.color, fontSize: 8, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  )),

            // Progress bar (if playing)
            if (_initialized)
              Positioned(
                bottom: 36,
                left: 12,
                right: 12,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: widget.borderColor,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),

            // Label bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.label,
                        style: TextStyle(color: widget.borderColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    Text(widget.hashLabel,
                        style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeatZone {
  final double? top, left, right, bottom, w, h;
  final Color color;
  final String label;
  const HeatZone({this.top, this.left, this.right, this.bottom, this.w, this.h, required this.color, required this.label});
}
