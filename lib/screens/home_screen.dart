import 'package:flutter/material.dart';
import 'productos_screen.dart';
import 'servicios_screen.dart';
import 'cotizador_screen.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductosScreen(),
    ServiciosScreen(),
    CotizadorScreen(),
    HistorialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.colorize), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.back_hand), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Cotizador'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}