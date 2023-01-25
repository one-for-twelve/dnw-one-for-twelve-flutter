import 'package:flutter/widgets.dart';

class SizeConfig {
  double? _screenWidth;
  double get screenWith => _screenWidth!;

  double? _screenHeight;
  double get screenHeight => _screenHeight!;

  double? _blockSizeHorizontal;
  double get blockSizeHorizontal => _blockSizeHorizontal!;

  double? _blockSizeVertical;
  double get blockSizeVertical => _blockSizeVertical!;

  double? _safeBlockHorizontal;
  double get safeBlockHorizontal => _safeBlockHorizontal!;

  double? _safeBlockVertical;
  double get safeBlockVertical => _safeBlockVertical!;

  SizeConfig(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    _screenWidth = mediaQueryData.size.width;
    _screenHeight = mediaQueryData.size.height;
    _blockSizeHorizontal = _screenWidth! / 100;
    _blockSizeVertical = _screenHeight! / 100;

    final safeAreaHorizontal =
        mediaQueryData.padding.left + mediaQueryData.padding.right;
    _safeBlockHorizontal = (_screenWidth! - safeAreaHorizontal) / 100;

    final safeAreaVertical =
        mediaQueryData.padding.top + mediaQueryData.padding.bottom;
    _safeBlockVertical = (_screenHeight! - safeAreaVertical) / 100;
  }
}
