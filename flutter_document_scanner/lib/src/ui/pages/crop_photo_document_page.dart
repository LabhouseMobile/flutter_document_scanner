// Copyright (c) 2021, Christian Betancourt
// https://github.com/criistian14
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:flutter_document_scanner/src/bloc/app/app_bloc.dart';
import 'package:flutter_document_scanner/src/bloc/app/app_event.dart';
import 'package:flutter_document_scanner/src/bloc/crop/crop_bloc.dart';
import 'package:flutter_document_scanner/src/bloc/crop/crop_event.dart';
import 'package:flutter_document_scanner/src/bloc/crop/crop_state.dart';
import 'package:flutter_document_scanner/src/utils/border_crop_area_painter.dart';
import 'package:flutter_document_scanner/src/utils/dot_utils.dart';

/// Page to crop a photo
class CropPhotoDocumentPage extends StatelessWidget {
  /// Create a page with style
  const CropPhotoDocumentPage({
    super.key,
    required this.cropPhotoDocumentStyle,
  });

  /// Style of the page
  final CropPhotoDocumentStyle cropPhotoDocumentStyle;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocSelector<AppBloc, AppState, File?>(
      selector: (state) => state.pictureInitial,
      builder: (context, state) {
        if (state == null) {
          return const Center(
            child: Text('NO IMAGE'),
          );
        }

        return BlocProvider(
          create: (context) => CropBloc(
            dotUtils: DotUtils(
              minDistanceDots: cropPhotoDocumentStyle.minDistanceDots,
            ),
            imageUtils: ImageUtils(),
          )..add(
              CropAreaInitialized(
                areaInitial: context.read<AppBloc>().state.contourInitial,
                defaultAreaInitial: cropPhotoDocumentStyle.defaultAreaInitial,
                image: state,
                screenSize: screenSize,
                positionImage: Rect.fromLTRB(
                  cropPhotoDocumentStyle.left,
                  cropPhotoDocumentStyle.top,
                  cropPhotoDocumentStyle.right,
                  cropPhotoDocumentStyle.bottom,
                ),
              ),
            ),
          child: _CropView(
            cropPhotoDocumentStyle: cropPhotoDocumentStyle,
            image: state,
          ),
        );
      },
    );
  }
}

class _CropView extends StatelessWidget {
  const _CropView({
    required this.cropPhotoDocumentStyle,
    required this.image,
  });
  final CropPhotoDocumentStyle cropPhotoDocumentStyle;
  final File image;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppBloc, AppState>(
          listenWhen: (previous, current) => current.statusCropPhoto != previous.statusCropPhoto,
          listener: (context, state) {
            if (state.statusCropPhoto == AppStatus.loading) {
              context.read<CropBloc>().add(CropPhotoByAreaCropped(image));
            }
          },
        ),
        BlocListener<CropBloc, CropState>(
          listenWhen: (previous, current) => current.imageCropped != previous.imageCropped,
          listener: (context, state) {
            if (state.imageCropped != null) {
              context.read<AppBloc>().add(
                    AppLoadCroppedPhoto(
                      image: state.imageCropped!,
                      area: state.areaParsed!,
                    ),
                  );
            }
          },
        ),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: cropPhotoDocumentStyle.top,
            bottom: cropPhotoDocumentStyle.bottom,
            left: cropPhotoDocumentStyle.left,
            right: cropPhotoDocumentStyle.right,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // * Photo
                Positioned.fill(
                  child: Image.file(
                    image,
                    fit: BoxFit.fill,
                  ),
                ),

                // * Border Mask
                BlocSelector<CropBloc, CropState, Area>(
                  selector: (state) => state.area,
                  builder: (context, state) {
                    return CustomPaint(
                      painter: BorderCropAreaPainter(
                        area: state,
                        colorBorderArea: cropPhotoDocumentStyle.colorBorderArea,
                        widthBorderArea: cropPhotoDocumentStyle.widthBorderArea,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),

                // * Dot - Top Left
                _buildDraggableDot(context, cropPhotoDocumentStyle, DotPosition.topLeft),

                // * Dot - Top Right
                _buildDraggableDot(context, cropPhotoDocumentStyle, DotPosition.topRight),

                // * Dot - Bottom Left
                _buildDraggableDot(context, cropPhotoDocumentStyle, DotPosition.bottomLeft),

                // * Dot - Bottom Right
                _buildDraggableDot(context, cropPhotoDocumentStyle, DotPosition.bottomRight),

                // * Side - Left
                _buildDraggableSide(context, cropPhotoDocumentStyle, SidePosition.left),

                // * Side - Right
                _buildDraggableSide(context, cropPhotoDocumentStyle, SidePosition.right),

                // * Side - Top
                _buildDraggableSide(context, cropPhotoDocumentStyle, SidePosition.top),

                // * Side - Bottom
                _buildDraggableSide(context, cropPhotoDocumentStyle, SidePosition.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDraggableDot(BuildContext context, CropPhotoDocumentStyle style, DotPosition position) {
  const invisiblePadding = 8.0;

  return BlocSelector<CropBloc, CropState, Point>(
    selector: (state) {
      switch (position) {
        case DotPosition.topLeft:
          return state.area.topLeft;
        case DotPosition.topRight:
          return state.area.topRight;
        case DotPosition.bottomLeft:
          return state.area.bottomLeft;
        case DotPosition.bottomRight:
          return state.area.bottomRight;
      }
    },
    builder: (context, point) {
      return Positioned(
        left: point.x - (style.dotSize / 2) - invisiblePadding,
        top: point.y - (style.dotSize / 2) - invisiblePadding,
        child: GestureDetector(
          onPanUpdate: (details) {
            context.read<CropBloc>().add(
                  CropDotMoved(
                    deltaX: details.delta.dx,
                    deltaY: details.delta.dy,
                    dotPosition: position,
                  ),
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(invisiblePadding),
            child: Container(
              color: Colors.transparent,
              width: style.dotSize,
              height: style.dotSize,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(style.dotRadius),
                  child: Container(
                    width: style.dotSize - (2 * 2),
                    height: style.dotSize - (2 * 2),
                    color: style.colorBorderArea,
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

Widget _buildDraggableSide(BuildContext context, CropPhotoDocumentStyle style, SidePosition position) {
  const invisiblePadding = 12.0;

  return BlocSelector<CropBloc, CropState, Area>(
    selector: (state) => state.area,
    builder: (context, area) {
      double _calculateAngle(Point<double> p1, Point<double> p2) {
        return atan2(p2.y - p1.y, p2.x - p1.x);
      }

      // Variables to hold the properties of the draggable side
      double angle;
      Point<double> start, end, middlePoint;

      // Define the size of the red container
      double redContainerWidth = 8;
      double redContainerHeight = 32;

      switch (position) {
        case SidePosition.left:
          start = area.topLeft;
          end = area.bottomLeft;
          angle = _calculateAngle(start, end) - pi / 2;
          redContainerWidth = style.smallSide;
          redContainerHeight = style.biggerSide;
          break;
        case SidePosition.right:
          start = area.topRight;
          end = area.bottomRight;
          angle = _calculateAngle(start, end) - pi / 2;
          redContainerWidth = style.smallSide;
          redContainerHeight = style.biggerSide;
          break;
        case SidePosition.top:
          start = area.topLeft;
          end = area.topRight;
          angle = _calculateAngle(start, end);
          redContainerWidth = style.biggerSide;
          redContainerHeight = style.smallSide;
          break;
        case SidePosition.bottom:
          start = area.bottomLeft;
          end = area.bottomRight;
          angle = _calculateAngle(start, end);
          redContainerWidth = style.biggerSide;
          redContainerHeight = style.smallSide;
          break;
      }

      // Calculate the middle point between start and end
      middlePoint = Point(
        (start.x + end.x) / 2,
        (start.y + end.y) / 2,
      );

      return Positioned(
        left: middlePoint.x - (redContainerWidth / 2) - invisiblePadding,
        top: middlePoint.y - (redContainerHeight / 2) - invisiblePadding,
        child: Transform.rotate(
          angle: angle,
          child: Padding(
            padding: const EdgeInsets.all(invisiblePadding),
            child: GestureDetector(
              onPanUpdate: (details) {
                context.read<CropBloc>().add(
                      CropSideMoved(
                        deltaX: details.delta.dx,
                        deltaY: details.delta.dy,
                        sidePosition: position,
                      ),
                    );
              },
              child: Container(
                width: redContainerWidth,
                height: redContainerHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  color: style.colorBorderArea,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
