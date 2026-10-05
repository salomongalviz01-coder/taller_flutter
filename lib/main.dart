import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 3 - Segundo plano y asincronía',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller 3 - Segundo Plano'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SeccionTitulo(texto: '1. Future / async / await'),
            SizedBox(height: 8),
            AsyncSection(),
            SizedBox(height: 28),
            SeccionTitulo(texto: '2. Cronómetro con Timer'),
            SizedBox(height: 8),
            TimerSection(),
            SizedBox(height: 28),
            SeccionTitulo(texto: '3. Tarea pesada con Isolate'),
            SizedBox(height: 8),
            IsolateSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SeccionTitulo extends StatelessWidget {
  final String texto;
  const SeccionTitulo({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

// ---------------------------------------------------------------------
// 1) SECCIÓN: Future / async / await
// ---------------------------------------------------------------------

enum _EstadoConsulta { inicial, cargando, exito, error }

class AsyncSection extends StatefulWidget {
  const AsyncSection({super.key});

  @override
  State<AsyncSection> createState() => _AsyncSectionState();
}

class _AsyncSectionState extends State<AsyncSection> {
  _EstadoConsulta _estado = _EstadoConsulta.inicial;
  String _mensaje = '';

  // Simula un servicio remoto con Future.delayed.
  Future<String> _consultarServicio() async {
    print('ANTES  -> Se inicia la consulta al servicio simulado');
    await Future.delayed(const Duration(seconds: 2));
    print('DURANTE -> Pasaron 2 segundos, el servicio ya respondió');

    final exito = DateTime.now().second % 2 == 0;
    if (!exito) {
      throw Exception('No se pudo conectar con el servicio');
    }
    return 'Datos recibidos: [12, 45, 78, 23]';
  }

  Future<void> _ejecutarConsulta() async {
    setState(() {
      _estado = _EstadoConsulta.cargando;
      _mensaje = '';
    });

    try {
      final resultado = await _consultarServicio();
      print('DESPUÉS -> Consulta finalizada con éxito');
      setState(() {
        _estado = _EstadoConsulta.exito;
        _mensaje = resultado;
      });
    } catch (e) {
      print('DESPUÉS -> Consulta finalizada con error: $e');
      setState(() {
        _estado = _EstadoConsulta.error;
        _mensaje = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _estado == _EstadoConsulta.cargando
                  ? null
                  : _ejecutarConsulta,
              child: const Text('Consultar datos'),
            ),
            const SizedBox(height: 16),
            if (_estado == _EstadoConsulta.cargando)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Cargando...'),
                ],
              ),
            if (_estado == _EstadoConsulta.exito)
              Text(
                '✅ Éxito: $_mensaje',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green),
              ),
            if (_estado == _EstadoConsulta.error)
              Text(
                '❌ Error: $_mensaje',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 2) SECCIÓN: Cronómetro con Timer
// ---------------------------------------------------------------------

class TimerSection extends StatefulWidget {
  const TimerSection({super.key});

  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> {
  Timer? _timer;
  int _segundos = 0;
  bool _corriendo = false;

  void _iniciar() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _segundos++);
    });
    setState(() => _corriendo = true);
  }

  void _pausar() {
    _timer?.cancel();
    _timer = null;
    setState(() => _corriendo = false);
  }

  void _reiniciar() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _segundos = 0;
      _corriendo = false;
    });
  }

  String get _tiempoFormateado {
    final minutos = (_segundos ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundos % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  void dispose() {
    // Limpieza de recursos: cancelar el timer al salir de la vista.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _tiempoFormateado,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _corriendo ? null : _iniciar,
                  child: Text(_segundos == 0 ? 'Iniciar' : 'Reanudar'),
                ),
                ElevatedButton(
                  onPressed: _corriendo ? _pausar : null,
                  child: const Text('Pausar'),
                ),
                OutlinedButton(
                  onPressed: _reiniciar,
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 3) SECCIÓN: Tarea pesada en un Isolate
// ---------------------------------------------------------------------

// Debe ser una función top-level o estática: es el entry point del isolate.
void _tareaPesada(SendPort sendPort) {
  int suma = 0;
  for (int i = 0; i < 800000000; i++) {
    suma += i;
  }
  sendPort.send(suma);
}

class IsolateSection extends StatefulWidget {
  const IsolateSection({super.key});

  @override
  State<IsolateSection> createState() => _IsolateSectionState();
}

class _IsolateSectionState extends State<IsolateSection> {
  bool _procesando = false;
  int? _resultado;
  int? _tiempoMs;

  Future<void> _ejecutarEnIsolate() async {
    setState(() {
      _procesando = true;
      _resultado = null;
      _tiempoMs = null;
    });

    print('Isolate: iniciando tarea pesada en segundo plano...');
    final cronometro = Stopwatch()..start();

    final receivePort = ReceivePort();
    await Isolate.spawn(_tareaPesada, receivePort.sendPort);
    final resultado = await receivePort.first as int;

    cronometro.stop();
    print(
      'Isolate: tarea finalizada. Resultado=$resultado '
      'en ${cronometro.elapsedMilliseconds} ms',
    );

    setState(() {
      _procesando = false;
      _resultado = resultado;
      _tiempoMs = cronometro.elapsedMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _procesando ? null : _ejecutarEnIsolate,
              child: const Text('Ejecutar tarea pesada'),
            ),
            const SizedBox(height: 16),
            if (_procesando)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Calculando en segundo plano (UI no se bloquea)...'),
                ],
              ),
            if (_resultado != null)
              Text(
                'Resultado: $_resultado\nTiempo: $_tiempoMs ms',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
