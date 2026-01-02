// ignore_for_file: file_names

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flip_card/flip_card.dart';

class EqualHeightFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final double defaultHeight;

  // ignore: use_super_parameters
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
        measuredHeight = newHeight; // her zaman ölçülen değere geç
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

    // Eğer ölçüm yapılmadıysa defaultHeight kullan, ölçüm sonrası her zaman measuredHeight
    final effectiveHeight = measuredHeight > 0
        ? measuredHeight
        : widget.defaultHeight;

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: SizedBox(
        key: frontKey,
        height: effectiveHeight,
        child: widget.front,
      ),
      back: SizedBox(key: backKey, height: effectiveHeight, child: widget.back),
    );
  }
}
