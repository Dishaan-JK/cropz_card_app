import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_email_auth/phone_email_auth.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PhoneEmail.initializeApp(clientId: '18298794129116369409');
  runApp(const ProviderScope(child: CropzApp()));
}
