import 'package:flutter/rendering.dart';

import '../app_localization.dart';

class GetRender {


  static double getRenderSize(context, String title, double fontSize) {
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: AppLocalizations.of(context)!.locale.languageCode == "Ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
    );

    return renderParagraph.getMinIntrinsicWidth(fontSize).ceilToDouble();
  }
}