import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vichaar/constant.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final int maxLines;

  ReadMoreText({required this.text, this.maxLines = 5});

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int maxLines = widget.maxLines;
        TextSpan textSpan = TextSpan(
          text: widget.text,
          
        );

        TextPainter textPainter = TextPainter(
          text: textSpan,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  
                  style: GoogleFonts.comfortaa(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.2,
                          height: 1.4
                  ),
                  children: [
                    TextSpan(
                      text: isExpanded
                          ? widget.text
                          : widget.text.substring(0, textPainter.getPositionForOffset(Offset(0, constraints.maxHeight * widget.maxLines)).offset),
                    ),
                    if (!isExpanded)
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = true;
                            });
                          },
                          child: Text(
                            '... Read more',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isExpanded)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = false;
                    });
                  },
                  child: Text(
                    ' Read less',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          );
        } else {
          return Text(widget.text,style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            //fontWeight: FontWeight.bold,
          ),);
        }
      },
    );
  }
}
