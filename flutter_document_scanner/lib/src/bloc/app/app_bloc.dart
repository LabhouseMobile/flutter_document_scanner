// Copyright (c) 2021, Christian Betancourt
// https://github.com/criistian14
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:flutter_document_scanner/src/bloc/app/app.dart';
import 'package:flutter_document_scanner/src/bloc/crop/crop.dart';

/// Controls interactions throughout the application by means
/// of the [DocumentScannerController]
class AppBloc extends Bloc<AppEvent, AppState> {
  /// Create instance AppBloc
  AppBloc({
    required ImageUtils imageUtils,
  })  : _imageUtils = imageUtils,
        super(AppState.init()) {
    on<AppExternalImageContoursFound>(_externalImageContoursFound);
    on<AppPhotoCropped>(_photoCropped);
    on<AppLoadCroppedPhoto>(_loadCroppedPhoto);
  }

  final ImageUtils _imageUtils;

  /// Find the contour from an external image like gallery
  Future<void> _externalImageContoursFound(
    AppExternalImageContoursFound event,
    Emitter<AppState> emit,
  ) async {
    final externalImage = event.image;

    final byteData = await externalImage.readAsBytes();
    final response = await _imageUtils.findContourPhoto(
      byteData,
      minContourArea: event.minContourArea,
    );

    emit(
      state.copyWith(
        pictureInitial: externalImage,
        contourInitial: response,
      ),
    );
  }

  /// It will change the state and
  /// execute the event [CropPhotoByAreaCropped] to crop the image that is in
  /// the [CropBloc].
  Future<void> _photoCropped(
    AppPhotoCropped event,
    Emitter<AppState> emit,
  ) async {
    emit(
      state.copyWith(
        statusCropPhoto: AppStatus.loading,
      ),
    );
  }

  /// It will change the state
  Future<void> _loadCroppedPhoto(
    AppLoadCroppedPhoto event,
    Emitter<AppState> emit,
  ) async {
    emit(
      state.copyWith(
        statusCropPhoto: AppStatus.success,
        pictureCropped: event.image,
        contourInitial: event.area,
      ),
    );
  }
}
