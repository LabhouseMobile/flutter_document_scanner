// Copyright (c) 2021, Christian Betancourt
// https://github.com/criistian14
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_document_scanner/src/models/area.dart';
import 'package:flutter_document_scanner/src/ui/pages/crop_photo_document_page.dart';
import 'package:flutter_document_scanner/src/utils/image_utils.dart';
import 'package:flutter_document_scanner/src/utils/model_utils.dart';

/// Status of the app
enum AppStatus {
  /// Is initializing
  initial,

  /// Is loading
  loading,

  /// Completed without errors
  success,

  /// An error occurred
  failure,
}

/// Pages of the app
enum AppPages {
  /// Reference to the page [CropPhotoDocumentPage]
  cropPhoto,
}

/// Controls the status general of the app
class AppState extends Equatable {
  /// Create an state instance
  const AppState({
    this.pictureInitial,
    this.statusCropPhoto = AppStatus.initial,
    this.contourInitial,
    this.pictureCropped,
  });

  /// Initial state
  factory AppState.init() {
    return const AppState();
  }

  /// Picture that was taken
  final File? pictureInitial;

  /// Status when the photo was cropped
  final AppStatus statusCropPhoto;

  /// Contour found with [ImageUtils.findContourPhoto]
  final Area? contourInitial;

  /// Picture that was cropped
  final Uint8List? pictureCropped;

  @override
  List<Object?> get props => [
        pictureInitial,
        statusCropPhoto,
        contourInitial,
        pictureCropped,
      ];

  /// Creates a copy of this state but with the given fields replaced with
  /// the new values.
  AppState copyWith({
    File? pictureInitial,
    AppStatus? statusCropPhoto,
    Object? contourInitial = valueNull,
    Uint8List? pictureCropped,
  }) {
    return AppState(
      pictureInitial: pictureInitial ?? this.pictureInitial,
      statusCropPhoto: statusCropPhoto ?? this.statusCropPhoto,
      contourInitial: contourInitial == valueNull ? this.contourInitial : contourInitial as Area?,
      pictureCropped: pictureCropped ?? this.pictureCropped,
    );
  }
}
