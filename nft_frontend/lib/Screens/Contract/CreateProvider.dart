import 'dart:io';

import 'package:flutter/material.dart';

class CreateProvider extends ChangeNotifier {
  File? _image;
  File? get image => _image;

  String? _description;
  String? get description => _description;

  void setImageFile(File newImage) {
    _image = newImage;
    notifyListeners();
  }

  void setDescription(String generated) {
    _description = generated;
    notifyListeners();
  }

  void clear() {
    _image = null;
    _description = null;
    notifyListeners();
  }
}
