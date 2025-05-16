import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final recadoController = TextEditingController();
  List<String> recados = [];

  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(16);
  late encrypt.Encrypter encrypter;

  @override
  void initState() {
    super.initState();
    encrypter = encrypt.Encrypter(encrypt.AES(key));
    _loadRecados();
  }

  Future<void> _loadRecados() async {
    final all = await storage.readAll();
    setState(() {
      recados = all.values.map((v) => encrypter.decrypt64(v, iv: iv)).toList();
    });
  }

  Future<void> _addRecado(String texto) async {
    final encrypted = encrypter.encrypt(texto, iv: iv).base64;
    await storage.write(
      key: DateTime.now().toIso8601String(),
      value: encrypted,
    );
    _loadRecados();
    recadoController.clear();
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Future<void> _clearRecados() async {
    await storage.deleteAll();
    _loadRecados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cofrinho Secreto"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: recadoController,
              decoration: InputDecoration(labelText: "Digite um recado"),
            ),
            ElevatedButton(
              onPressed: () => _addRecado(recadoController.text),
              child: Text("Salvar Recado"),
            ),
            ElevatedButton(
              onPressed: _clearRecados,
              child: Text("Apagar Tudo"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recados.length,
                itemBuilder:
                    (context, index) => ListTile(title: Text(recados[index])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
