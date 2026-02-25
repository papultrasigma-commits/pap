
import 'package:flutter/material.dart';
import '../app_store.dart';
import 'create_profile_page.dart';
import 'profile_page.dart';

class ProfilesPage extends StatelessWidget {
  final AppStore store;
  const ProfilesPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    if (!store.hasProfile) {
      return CreateProfilePage(store: store);
    }
    return ProfilePage(store: store);
  }
}
