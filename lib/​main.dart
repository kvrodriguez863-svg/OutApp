import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const ChatSeguroApp());
}

class ChatSeguroApp extends StatelessWidget {
  const ChatSeguroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Seguro Real',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.orange,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.deepOrange,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PantallaLoginReal(),
        '/registro_perfil': (context) => const PantallaRegistroPerfil(),
        '/home': (context) => const PantallaPrincipal(),
        '/chat': (context) => const PantallaChat(),
      },
    );
  }
}

// 1. PANTALLA DE ACCESO BIOMÉTRICO Y PIN REAL
class PantallaLoginReal extends StatefulWidget {
  const PantallaLoginReal({Key? key}) : super(key: key);

  @override
  State<PantallaLoginReal> createState() => _PantallaLoginRealState();
}

class _PantallaLoginRealState extends State<PantallaLoginReal> {
  final LocalAuthentication _auth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  bool _autenticando = false;

  Future<void> _autenticarConHuella() async {
    bool autenticado = false;
    try {
      setState(() => _autenticando = true);
      bool puedeVerificar = await _auth.canCheckBiometrics;
      if (!puedeVerificar) {
        puedeVerificar = await _auth.isDeviceSupported();
      }

      if (puedeVerificar) {
        autenticado = await _auth.authenticate(
          localizedReason: 'Escanea tu huella para acceder al chat',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      }
    } catch (e) {
      print("Error biométrico: $e");
    } finally {
      setState(() => _autenticando = false);
    }

    if (autenticado) {
      Navigator.pushReplacementNamed(context, '/registro_perfil');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación fallida o cancelada')),
      );
    }
  }

  void _verificarPin() {
    if (_pinController.text == '1234') {
      Navigator.pushReplacementNamed(context, '/registro_perfil');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto. Prueba con 1234 o usa huella.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad Requerida')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.orangeAccent),
              const SizedBox(height: 20),
              const Text("Protección de Identidad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Usa tu huella digital o ingresa tu clave de 4 dígitos.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _autenticando ? null : _autenticarConHuella,
                icon: const Icon(Icons.fingerprint, size: 28),
                label: Text(_autenticando ? 'Escaneando...' : 'Desbloquear con Huella'),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.grey),
              const SizedBox(height: 20),

              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: _verificarPin,
                child: const Text('Confirmar PIN de 4 Dígitos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. PANTALLA PARA CARGAR FOTO DE PERFIL
class PantallaRegistroPerfil extends StatefulWidget {
  const PantallaRegistroPerfil({Key? key}) : super(key: key);

  @override
  State<PantallaRegistroPerfil> createState() => _PantallaRegistroPerfilState();
}

class _PantallaRegistroPerfilState extends State<PantallaRegistroPerfil> {
  File? _imagenPerfil;
  final TextEditingController _nombreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarFoto(ImageSource origen) async {
    final XFile? imagen = await _picker.pickImage(source: origen, imageQuality: 50);
    if (imagen != null) {
      setState(() {
        _imagenPerfil = File(imagen.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configura tu Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    height: 150,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt, color: Colors.orangeAccent),
                          title: const Text('Tomar una foto con la cámara'),
                          onTap: () {
                            Navigator.pop(context);
                            _seleccionarFoto(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
                          title: const Text('Elegir de la galería'),
                          onTap: () {
                            Navigator.pop(context);
                            _seleccionarFoto(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage: _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
                child: _imagenPerfil == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.orangeAccent)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Tu Nombre o Alias',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa un nombre')),
                  );
                  return;
                }
                Navigator.pushReplacementNamed(context, '/home', arguments: _imagenPerfil);
              },
              child: const Text('Entrar al Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. PANTALLA PRINCIPAL
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final File? fotoPerfil = ModalRoute.of(context)!.settings.arguments as File?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja Segura'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: fotoPerfil != null ? FileImage(fotoPerfil) : null,
            child: fotoPerfil == null ? const Icon(Icons.person) : null,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.cyan, child: Icon(Icons.person, color: Colors.black)),
            title: const Text('Grupo de Trabajo Industrial'),
            subtitle: const Text('Chats cifrados y moderados...'),
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),
        ],
      ),
    );
  }
}

// 4. PANTALLA DE CHAT (Filtro de CBU activo)
class PantallaChat extends StatefulWidget {
  const PantallaChat({Key? key}) : super(key: key);

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _mensajes = [];

  void _enviar() {
    String txt = _msgController.text.trim();
    if (txt.isEmpty) return;

    String lower = txt.toLowerCase();
    if (lower.contains('cbu') || lower.contains('alias') || lower.contains('banco') || lower.contains('cvu')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mensaje Bloqueado 🛡️', style: TextStyle(color: Colors.redAccent)),
          content: const Text('Está prohibido enviar datos bancarios (CBU/Alias) por este chat de texto. Usa nota de voz.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))],
        ),
      );
      return;
    }

    setState(() {
      _mensajes.add(txt);
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Seguro 1 a 1')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _mensajes.length,
              itemBuilder: (context, i) => ListTile(title: Text(_mensajes[i])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'Escribe mensaje seguro...'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.orangeAccent), onPressed: _enviar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
