import 'package:flutter/material.dart';

class SmoothHighlight extends StatefulWidget {
  const SmoothHighlight({
    super.key,
    required this.child,
    required this.color,
    this.enabled = true,
    this.useInitialHighLight = false,
    this.padding = EdgeInsets.zero,
    this.initialHighlightDelay = Duration.zero,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  /// Highlight target widget.
  ///
  /// If child has no size, it will be nothing happened.
  final Widget child;

  /// The highlight color.
  ///
  /// If [enabled] is false, this color is not used.
  final Color color;

  /// Whether this highlight is enabled.
  ///
  /// If false, the child does not be highlight at all. default to true.
  /// Ex. `enabled: count % 2 ==0` means that highlight if count is only even.
  final bool enabled;

  /// Whether this highlight works also in initState phase.
  ///
  /// If true, the highlight will be applied to the child in initState phase. default to false.
  final bool useInitialHighLight;

  /// Delay duration for initial highlight.
  ///
  /// If set, the initial highlight will be delayed. default to Duration.zero.
  final Duration initialHighlightDelay;

  /// Animation duration.
  ///
  /// Default to 500ms.
  final Duration animationDuration;

  /// The padding of the highlight.
  final EdgeInsets padding;

  @override
  State<SmoothHighlight> createState() => _SmoothHighlightState();
}

class _SmoothHighlightState extends State<SmoothHighlight>
    with SingleTickerProviderStateMixin {
  bool _disposed = false;
  late final _animationController = AnimationController(
    vsync: this,
    duration:  widget.animationDuration,
  );
  late final Animation<Decoration> _animation = _animationController
      .drive(
        CurveTween(curve: Curves.easeInOut),
      )
      .drive(
        DecorationTween(
          begin: const BoxDecoration(),
          end: BoxDecoration(
            color: widget.color,
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    if (widget.useInitialHighLight) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(widget.initialHighlightDelay);
        _animationController.forward();
      });
    }
    _animation.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        // this is workaround for following error occurs if you use in ListView scroll:
        // `called after AnimationController.dispose() AnimationController methods should not be used after calling dispose.`
        if (!_disposed) {
          await _animationController.reverse();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant SmoothHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Padding(padding: widget.padding, child: widget.child);

    return widget.enabled
        ? DecoratedBoxTransition(
            decoration: _animation,
            child: child,
          )
        : child;
  }
}
