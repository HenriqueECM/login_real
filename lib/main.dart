import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_real/home_page.dart';
import 'package:login_real/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://<your-project>.supabase.co',
    anonKey: '<your-anon-key>',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return snapshot.data! ? HomePage() : LoginPage();
        },
      ),
    );
  }
}
