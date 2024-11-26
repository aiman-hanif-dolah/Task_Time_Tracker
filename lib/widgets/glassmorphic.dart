import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatefulWidget {
  final Widget child;

  const GlassmorphicContainer({super.key, required this.child});

  @override
  _GlassmorphicContainerState createState() => _GlassmorphicContainerState();
}

class _GlassmorphicContainerState extends State<GlassmorphicContainer> {
  bool _isHovered = false;

  void _onHover(PointerEvent details) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHover,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          gradient: LinearGradient(
            colors: _isHovered
                ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.15)]
                : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovered ? 0.3 : 0.2),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.1), // Additional color layer for a more pronounced effect
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
