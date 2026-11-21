import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Plays a short decaying horizontal shake whenever [shakeCount] increments.
///
/// Uses a bounded 300ms animation so Flutter widget tests settle cleanly.
class TactileShakeWrapper extends StatefulWidget {
  const TactileShakeWrapper({
    super.key,
    required this.shakeCount,
    required this.child,
    this.amplitude = 7.0,
  });

  final int shakeCount;
  final Widget child;
  final double amplitude;

  @override
  State<TactileShakeWrapper> createState() => _TactileShakeWrapperState();
}

class _TactileShakeWrapperState extends State<TactileShakeWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant TactileShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeCount > oldWidget.shakeCount &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offsetX = t == 0 || t == 1
            ? 0.0
            : math.sin(t * math.pi * 4) * (1 - t) * widget.amplitude;
        return Transform.translate(offset: Offset(offsetX, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Provides subtle stone-button press compression + snap release on touch.
class TactilePressScale extends StatefulWidget {
  const TactilePressScale({
    super.key,
    required this.enabled,
    required this.child,
    this.pressedScale = 0.96,
  });

  final bool enabled;
  final Widget child;
  final double pressedScale;

  @override
  State<TactilePressScale> createState() => _TactilePressScaleState();
}

class _TactilePressScaleState extends State<TactilePressScale> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (!widget.enabled || _isPressed == pressed) {
      return;
    }
    setState(() => _isPressed = pressed);
  }

  @override
  void didUpdateWidget(covariant TactilePressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _isPressed) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final scale = (_isPressed && widget.enabled) ? widget.pressedScale : 1.0;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
