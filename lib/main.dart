import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 1 - Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado que guarda el título actual de la AppBar.
  String _titulo = 'Hola, Flutter';

  void _cambiarTitulo() {
    setState(() {
      _titulo = _titulo == 'Hola, Flutter'
          ? '¡Título cambiado!'
          : 'Hola, Flutter';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Título actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre del estudiante, centrado.
            const Text(
              'Salomon Galviz',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Row con Image.network() e Image.asset()
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.network(
                    'https://picsum.photos/id/237/300/300',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Image.asset(
                    'assets/images/foto.png',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón obligatorio: cambia el título con setState() y muestra SnackBar
            ElevatedButton(
              onPressed: _cambiarTitulo,
              child: const Text('Cambiar título'),
            ),
            const SizedBox(height: 24),

            // Widget adicional 1: Container con margen, color y borde
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo, width: 1.5),
              ),
              child: const Text(
                'Este es un Container con color, borde y márgenes.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Widget adicional 2: ListView con 4 elementos (icono + texto)
            const Text(
              'Lista de elementos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.flutter_dash, color: Colors.indigo),
                    title: Text('Flutter'),
                  ),
                  ListTile(
                    leading: Icon(Icons.code, color: Colors.indigo),
                    title: Text('Dart'),
                  ),
                  ListTile(
                    leading: Icon(Icons.storage, color: Colors.indigo),
                    title: Text('Git'),
                  ),
                  ListTile(
                    leading: Icon(Icons.cloud, color: Colors.indigo),
                    title: Text('GitHub'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Widget adicional 3 (extra): ElevatedButton.icon
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acción adicional ejecutada')),
                );
              },
              icon: const Icon(Icons.thumb_up),
              label: const Text('Acción adicional'),
            ),
          ],
        ),
      ),
    );
  }
}
