import 'package:flutter/material.dart';

class WiFiAnimation extends StatefulWidget {
  final double size;

  const WiFiAnimation({
    Key? key,
    this.size = 256,
  }) : super(key: key);

  @override
  _WiFiAnimationState createState() => _WiFiAnimationState();
}

class _WiFiAnimationState extends State<WiFiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Ripeti l'animazione all'infinito
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.size * 0.8,
        height: widget.size * 0.8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Segmento fisso (il cerchio inferiore)
            Positioned(
              top: widget.size * 0.15, // Posiziona il cerchio inferiore
              child: Image.asset(
                'assets/logo-segment-1.png',
                width: widget.size * 0.8, // Adatta la dimensione
                height: widget.size * 0.8, // Adatta la dimensione
                fit: BoxFit.contain,
              ),
            ),
            // Segmento 2 (animato)
            Positioned(
              top: widget.size * 0.05, // Posiziona sopra il segmento 1
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_controller.value * 3).floor() == 0 ? 1.0 : 0.3,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/logo-segment-2.png',
                  width: widget.size * 0.8, // Adatta la dimensione
                  height: widget.size * 0.8, // Adatta la dimensione
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Segmento 3 (animato)
            Positioned(
              bottom: widget.size * 0.05, // Posiziona sopra il segmento 2
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_controller.value * 3).floor() == 1 ? 1.0 : 0.3,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/logo-segment-3.png',
                  width: widget.size * 0.8, // Adatta la dimensione
                  height: widget.size * 0.8, // Adatta la dimensione
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Segmento 4 (animato)
            Positioned(
              bottom: widget.size * 0.15, // Posiziona sopra il segmento 3
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_controller.value * 3).floor() == 2 ? 1.0 : 0.3,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/logo-segment-4.png',
                  width: widget.size * 0.8, // Adatta la dimensione
                  height: widget.size * 0.8, // Adatta la dimensione
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ));
  }
}
