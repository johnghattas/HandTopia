import 'package:flutter/material.dart';

class CustomAnimationButton extends StatefulWidget {
  final double height;
  final double width;
  final Color color;

  final VoidCallback onPressed;

  final Icon icon;

  const CustomAnimationButton({Key? key, this.height = 50, this.width = 100, this.color = Colors.white, required this.onPressed, this.icon = const Icon(
    Icons.shopping_cart,
    color: Colors.blue,
    size: 30,
  )}) : super(key: key);

  @override
  _CustomAnimationButtonState createState() => _CustomAnimationButtonState();
}

class _CustomAnimationButtonState extends State<CustomAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
    _sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1), weight: 50),
    ]).animate(_controller);


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        if (widget.onPressed == null) {
          return;
        }
        if (_controller.isCompleted) {
          _controller.reset();
        }
        _controller.forward();
        widget.onPressed();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(boxShadow: [

              ], borderRadius: BorderRadius.circular(10), color: widget.color),
              constraints: BoxConstraints.expand(),
            ),
            Positioned(
              child: AnimatedBuilder(
                builder: (context, child) =>Transform.scale(
                  scale: _sizeAnimation.value,
                  origin: Offset(0, 0),
                  child: Center(
                      child: widget.icon
                  ),
                ),
                animation: _controller,
              ),
            )
          ],
        ),
      ),
    );
  }
}