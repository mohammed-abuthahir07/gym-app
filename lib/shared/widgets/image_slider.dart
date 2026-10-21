import 'package:flutter/material.dart';

/// Auto-playing image slider with dot indicators.
class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final Duration autoPlayDuration;
  final List<String>? captions;
  final Widget? overlayContent;

  const ImageSlider({
    super.key,
    required this.imagePaths,
    this.height = 220,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.captions,
    this.overlayContent,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late final List<String> _paths;

  @override
  void initState() {
    super.initState();
    _paths = widget.imagePaths.where((p) => p.isNotEmpty).toList();
    if (_paths.length > 1) {
      Future.delayed(widget.autoPlayDuration, _autoPlay);
    }
  }

  void _autoPlay() {
    if (!mounted) return;
    final next = (_currentIndex + 1) % _paths.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    Future.delayed(widget.autoPlayDuration, _autoPlay);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_paths.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          color: Colors.black26,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.white30,
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _paths.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _paths[i],
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, st) => Container(
                      color: Colors.black38,
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),
                  // Dark gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Overlay content (e.g., welcome text)
          if (widget.overlayContent != null)
            Positioned.fill(child: widget.overlayContent!),

          // Caption at bottom
          if (widget.captions != null &&
              widget.captions!.length > _currentIndex)
            Positioned(
              bottom: 36,
              left: 16,
              right: 16,
              child: Text(
                widget.captions![_currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Dot indicators
          if (_paths.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_paths.length, (i) {
                  final isActive = i == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
