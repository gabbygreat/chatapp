import 'package:flutter/material.dart';

class MyChatBubble extends StatelessWidget {
  final double bubbleRadius;
  final Color color;
  final String text;
  final String uuid;
  final String messageUiid;
  final TextStyle textStyle;

  const MyChatBubble({
    Key? key,
    required this.text,
    this.bubbleRadius = 16,
    required this.messageUiid,
    required this.uuid,
    this.color = Colors.lightBlue,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          messageUiid == uuid ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(bubbleRadius),
                  topRight: Radius.circular(bubbleRadius),
                  bottomLeft: const Radius.circular(0),
                  bottomRight: Radius.circular(bubbleRadius),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Text(
                      text,
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
