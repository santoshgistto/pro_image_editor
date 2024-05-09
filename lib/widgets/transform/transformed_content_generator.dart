import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../models/crop_rotate_editor/transform_factors.dart';

class TransformedContentGenerator extends StatefulWidget {
  final Widget child;
  final TransformConfigs transformConfigs;
  final ProImageEditorConfigs configs;
  final bool fitToScreenSize;
  final Size bodySize;
  final Size mainImageSize;
  final Size decodedImageSize;

  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
    required this.configs,
    this.fitToScreenSize = true,
    this.mainImageSize = Size.zero,
    this.bodySize = Size.zero,
    this.decodedImageSize = Size.zero,
    super.key,
  });

  @override
  State<TransformedContentGenerator> createState() =>
      _TransformedContentGeneratorState();
}

class _TransformedContentGeneratorState
    extends State<TransformedContentGenerator> {
  @override
  Widget build(BuildContext context) {
    // TODO: remove timeDilation
    timeDilation = 2.5;
    return LayoutBuilder(
      builder: (context, constraints) {
        TransformConfigs configs = widget.transformConfigs;
        Size size = constraints.biggest;

        double scaleHelper = 1;

/* 
     if (configs.cropEditorScreenRatio != 0) {
          bool beforeFitToWidth = configs.cropEditorScreenRatio < configs.originalSize.aspectRatio;
          bool afterFitToWidth = configs.cropEditorScreenRatio < configs.cropRect.size.aspectRatio;

          print(configs.cropRect.size);
          print(beforeFitToWidth);
          print(afterFitToWidth);

          if (configs.is90DegRotated) {
            if (beforeFitToWidth && afterFitToWidth) {
              scaleHelper = configs.cropEditorScreenRatio / size.aspectRatio;
            }
          } else {
            if (!beforeFitToWidth && afterFitToWidth) {
              scaleHelper = size.aspectRatio / configs.cropEditorScreenRatio;
            } else if (beforeFitToWidth && !afterFitToWidth) {
              scaleHelper = configs.cropEditorScreenRatio / size.aspectRatio;
            }
          }
        }
 */
        if (configs.cropEditorScreenRatio != 0) {
          bool beforeOriginalFitToWidth =
              configs.cropEditorScreenRatio < configs.originalSize.aspectRatio;
          bool afterOriginalFitToWidth =
              size.aspectRatio < configs.originalSize.aspectRatio;
          bool beforeFitToWidth =
              configs.cropEditorScreenRatio < configs.cropRect.size.aspectRatio;
          bool afterFitToWidth =
              size.aspectRatio < configs.cropRect.size.aspectRatio;

          /*  print('--------------------');
          print(beforeOriginalFitToWidth);
          print(afterOriginalFitToWidth);
          print(beforeFitToWidth);
          print(afterFitToWidth); */

          if (configs.is90DegRotated) {
            if (beforeFitToWidth && afterFitToWidth) {
              scaleHelper = configs.cropEditorScreenRatio / size.aspectRatio;
            }
          } else {
            if (!beforeOriginalFitToWidth && beforeFitToWidth) {
              scaleHelper = size.aspectRatio / configs.cropEditorScreenRatio;
            } else if (beforeOriginalFitToWidth && !beforeFitToWidth) {
              scaleHelper = configs.cropEditorScreenRatio / size.aspectRatio;
            }
          }
        }

        return FittedBox(
          child: Container(
            color: Colors.amber.withOpacity(0.3),
            width: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.width,
            height: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.height,
            child: Transform.scale(
              scale: scaleHelper,
              child: _buildRotationTransform(
                child: _buildFlipTransform(
                  child: _buildRotationScaleTransform(
                    child: _buildCropPainter(
                      child: _buildUserScaleTransform(
                        child: _buildTranslate(
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Transform _buildRotationTransform({required Widget child}) {
    return Transform.rotate(
      angle: widget.transformConfigs.angle,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: widget.transformConfigs.flipX,
      flipY: widget.transformConfigs.flipY,
      child: child,
    );
  }

  Transform _buildRotationScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: widget.transformConfigs.scaleRotation,
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    CutOutsideArea clipper = CutOutsideArea(configs: widget.transformConfigs);

    if (widget.configs.cropRotateEditorConfigs.roundCropper) {
      return ClipOval(clipper: clipper, child: child);
    } else {
      return ClipRect(clipper: clipper, child: child);
    }
  }

  Transform _buildUserScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: widget.transformConfigs.scaleUser,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildTranslate({required Widget child}) {
    return Transform.translate(
      offset: widget.transformConfigs.offset,
      child: child,
    );
  }
}

class CutOutsideArea extends CustomClipper<Rect> {
  final TransformConfigs configs;

  CutOutsideArea({
    required this.configs,
  });
  @override
  Rect getClip(Size size) {
    Rect cropRect = configs.cropRect;

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropRect.width,
      height: cropRect.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! CutOutsideArea || oldClipper.configs != configs;
  }
}

bool _stickToWidth(double ratioOld, double ratioNew) => ratioOld <= ratioNew;
