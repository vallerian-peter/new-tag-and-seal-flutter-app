import 'package:flutter/material.dart';

class FloatingTag extends StatefulWidget {
  final String text;
  final double left;
  final double top;
  final Color textColor;
  final double fontSize;
  final Duration animationDuration;
  final double bounceHeight;

  const FloatingTag({
    Key? key,
    required this.text,
    required this.left,
    required this.top,
    this.textColor = Colors.white,
    this.fontSize = 12.0,
    this.animationDuration = const Duration(seconds: 2),
    this.bounceHeight = 10.0,
  }) : super(key: key);

  @override
  State<FloatingTag> createState() => _FloatingTagState();
}

class _FloatingTagState extends State<FloatingTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: widget.bounceHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the bounce animation and repeat it
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(115, 78, 78, 78),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 48, 48, 48).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '⌘',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white
                      ),
                    ),
                  ),

                  const SizedBox(width: 3,),

                  Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
