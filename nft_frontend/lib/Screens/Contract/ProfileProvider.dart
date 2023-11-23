import 'package:flutter/material.dart';

// Ye isi liye yaar ki , jo apna user aayega , usko sb details dikhaye.
// agar kisi aur user ka to usmai kuchh kuchh rok denge.
// View create krne ke liye.

class ProfileProvider extends ChangeNotifier {
  bool _profileStatus = true;
  bool get profileStatus => _profileStatus;

  void setProfile(bool newProfileStatus) {
    _profileStatus = newProfileStatus;
    notifyListeners();
  }
}
