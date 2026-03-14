import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CropHelper {
  CropHelper._();

  // Opens the native crop UI and returns the cropped file.
  // Returns null if the user cancels.
  static Future<File?> crop(String sourcePath, BuildContext context) async {
    final cs = Theme.of(context).colorScheme;

    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop your skin area',
          toolbarColor: cs.surface,
          toolbarWidgetColor: cs.onSurface,
          statusBarColor: cs.surface,
          activeControlsWidgetColor: cs.primary,
          backgroundColor: cs.surface,
          // Free-form crop so user can select any skin region
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop your skin area',
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }
}
