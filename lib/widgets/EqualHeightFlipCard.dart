// ignore_for_file: file_names, use_super_parameters

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flip_card/flip_card.dart';

class EqualHeightFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final double defaultHeight;

  const EqualHeightFlipCard({
    required this.front,
    required this.back,
    this.defaultHeight = 200,
    Key? key,
  }) : super(key: key);

  @override
  State<EqualHeightFlipCard> createState() => _EqualHeightFlipCardState();
}

class _EqualHeightFlipCardState extends State<EqualHeightFlipCard> {
  final frontKey = GlobalKey();
  final backKey = GlobalKey();
  double measuredHeight = 0;

  void _updateHeight() {
    final frontSize = frontKey.currentContext?.size?.height ?? 0;
    final backSize = backKey.currentContext?.size?.height ?? 0;
    final newHeight = frontSize > backSize ? frontSize : backSize;

    if (newHeight > 0 && newHeight != measuredHeight) {
      setState(() {
        measuredHeight = newHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

    if (measuredHeight == 0) {
      _updateHeight();
    }
    final effectiveHeight = measuredHeight > 0 ? measuredHeight : null;

    return SizedBox(
      height: effectiveHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              spreadRadius: 0.2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: FlipCard(
          direction: FlipDirection.HORIZONTAL,
          front: Container(key: frontKey, child: widget.front),
          back: Container(key: backKey, child: widget.back),
        ),
      ),
    );
  }
}
