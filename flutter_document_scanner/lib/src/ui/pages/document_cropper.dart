// Copyright (c) 2021, Christian Betancourt
// https://github.com/criistian14
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_document_scanner/src/document_scanner_controller.dart';
import 'package:flutter_document_scanner/src/ui/pages/crop_photo_document_page.dart';
import 'package:flutter_document_scanner/src/utils/crop_photo_document_style.dart';
import 'package:flutter_document_scanner/src/utils/general_styles.dart';

/// This class is the main page of the application
class DocumentCropper extends StatelessWidget {
  /// Create a main page with properties and methods
  /// to manage the document scanner.
  const DocumentCropper({
    super.key,
    this.controller,
    this.generalStyles = const GeneralStyles(),
    this.pageTransitionBuilder,
    this.cropPhotoDocumentStyle = const CropPhotoDocumentStyle(),
  });

  /// Controller to execute the different functionalities
  /// using the [DocumentScannerController]
  final DocumentScannerController? controller;

  /// [generalStyles] is the [GeneralStyles] that will be used to style the
  /// [DocumentCropper] widget.
  final GeneralStyles generalStyles;

  /// To change the animation performed when switching between screens
  /// by using the [AnimatedSwitcherTransitionBuilder]
  final AnimatedSwitcherTransitionBuilder? pageTransitionBuilder;

  /// It is used to change the style of the [CropPhotoDocumentPage] page
  /// using the [CropPhotoDocumentStyle] class.
  final CropPhotoDocumentStyle cropPhotoDocumentStyle;

  @override
  Widget build(BuildContext context) {
    DocumentScannerController _controller = DocumentScannerController();

    if (controller != null) {
      _controller = controller!;
    }

    return BlocProvider(
      create: (BuildContext context) => _controller.bloc,
      child: RepositoryProvider<DocumentScannerController>(
        create: (context) => _controller,
        child: ColoredBox(
          color: generalStyles.baseColor,
          child: _View(
            pageTransitionBuilder: pageTransitionBuilder,
            generalStyles: generalStyles,
            cropPhotoDocumentStyle: cropPhotoDocumentStyle,
          ),
        ),
      ),
    );
  }
}

class _View extends StatelessWidget {
  const _View({
    this.pageTransitionBuilder,
    required this.generalStyles,
    required this.cropPhotoDocumentStyle,
  });

  final AnimatedSwitcherTransitionBuilder? pageTransitionBuilder;
  final GeneralStyles generalStyles;
  final CropPhotoDocumentStyle cropPhotoDocumentStyle;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final Widget page = CropPhotoDocumentPage(
      cropPhotoDocumentStyle: cropPhotoDocumentStyle,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: pageTransitionBuilder ??
          (child, animation) {
            const begin = Offset(-1, 0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
      child: page,
    );
  }
}
