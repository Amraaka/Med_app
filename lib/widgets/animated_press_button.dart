import 'package:flutter/material.dart';

/// A wrapper that adds press animation to any button widget.
/// Scales down slightly when pressed for tactile feedback.
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleAmount;
  final Duration duration;

  const AnimatedPressButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleAmount = 0.96,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleAmount : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Extension method for easy wrapping of buttons with press animation
extension AnimatedPressExtension on Widget {
  Widget withPressAnimation({VoidCallback? onPressed}) {
    return AnimatedPressButton(onPressed: onPressed, child: this);
  }
}
