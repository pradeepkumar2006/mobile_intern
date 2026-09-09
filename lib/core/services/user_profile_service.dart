import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  static UserProfileService get instance => _instance;

  UserProfileService._internal();

  UserProfileModel? _currentProfile;
  bool _isInitialized = false;

  UserProfileModel get profile =>
      _currentProfile ?? UserProfileModel.defaultProfile();

  bool get isProfileCompleted => _currentProfile?.isProfileCompleted ?? false;
  bool get isInitialized => _isInitialized;

  String _getStorageKey() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.uid.isNotEmpty) {
          return 'trylo_profile_${user.uid}';
        }
      }
    } catch (_) {}
    return 'trylo_profile_current';
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      final jsonStr = prefs.getString(key) ?? prefs.getString('trylo_profile_current');

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        _currentProfile = UserProfileModel.fromJson(data);
      } else {
        if (Firebase.apps.isNotEmpty) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final defaultData = UserProfileModel.defaultProfile();
            _currentProfile = defaultData.copyWith(
              id: user.uid,
              name: (user.displayName != null && user.displayName!.isNotEmpty)
                  ? user.displayName!
                  : (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                      ? user.phoneNumber!
                      : defaultData.name,
              avatarPath: user.photoURL,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('UserProfileService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfileModel newProfile) async {
    _currentProfile = newProfile.copyWith(isProfileCompleted: true);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      final jsonStr = jsonEncode(_currentProfile!.toJson());
      await prefs.setString(key, jsonStr);
      await prefs.setString('trylo_profile_current', jsonStr);

      if (Firebase.apps.isNotEmpty) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && newProfile.name.isNotEmpty) {
            await user.updateDisplayName(newProfile.name);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('UserProfileService saveProfile error: $e');
    }
  }

  Future<void> clearProfile() async {
    _currentProfile = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('trylo_profile_current');
    } catch (e) {
      debugPrint('UserProfileService clearProfile error: $e');
    }
  }
}
