// Copyright (c) 2021, Christian Betancourt
// https://github.com/criistian14
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:flutter_document_scanner/src/bloc/app/app.dart';
import 'package:flutter_document_scanner/src/ui/pages/crop_photo_document_page.dart';

/// This class is responsible for controlling the scanning process
class DocumentScannerController {
  /// Creates a new instance of the [AppBloc]
  final AppBloc _appBloc = AppBloc(
    imageUtils: ImageUtils(),
  );

  /// Return the [AppBloc] created
  AppBloc get bloc => _appBloc;

  /// Stream [AppStatus] to know the status while the document is being cropped
  Stream<AppStatus> get statusCropPhoto {
    return _appBloc.stream.map((data) => data.statusCropPhoto).distinct();
  }

  /// Will return the picture cropped on the [CropPhotoDocumentPage].
  Uint8List? get pictureCropped => _appBloc.state.pictureCropped;

  Area? get area => _appBloc.state.contourInitial;

  /// Find the contour from an external image like gallery
  ///
  /// [minContourArea] is default 80000.0
  Future<void> findContoursFromExternalImage({
    required File image,
    double? minContourArea,
  }) async {
    _appBloc.add(
      AppExternalImageContoursFound(
        image: image,
        minContourArea: minContourArea,
      ),
    );
  }

  Future<void> setInitialPicture({
    required File initialPicture,
    required Area? area,
  }) async {
    _appBloc.add(
      AppSetInitialPicture(
        initialPicture: initialPicture,
        area: area,
      ),
    );
  }

  /// Cutting the photo and adjusting the perspective
  Future<void> cropPhoto() async {
    _appBloc.add(AppPhotoCropped());
  }

  /// Dispose the [AppBloc]
  void dispose() {
    _appBloc.close();
  }
}
