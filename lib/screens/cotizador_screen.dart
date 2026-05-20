import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/producto.dart';
import '../models/servicio.dart';
import '../models/cotizacion.dart';
import '../theme/app_theme.dart';

class CotizadorScreen extends StatefulWidget {
  const CotizadorScreen({super.key});

  @override
  State<CotizadorScreen> createState() => _CotizadorScreenState();
}

class _CotizadorScreenState extends State<CotizadorScreen> with SingleTickerProviderStateMixin {
  List<Producto> _productos = [];
  List<Servicio> _servicios = [];
  List<CotizacionItem> _seleccionados = [];
  final _notasCtrl = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  Future<void> _cargar() async {
    final productos = await DBHelper.instance.getProductos();
    final servicios = await DBHelper.instance.getServicios();
    setState(() {
      _productos = productos;
      _servicios = servicios;
    });
  }

  double get _total => _seleccionados.fold(0, (sum, item) => sum + item.subtotal);

  void _agregar(String nombre, double precio, String tipo) {
    setState(() {
      final idx = _seleccionados.indexWhere((s) => s.nombre == nombre && s.tipo == tipo);
      if (idx >= 0) {
        _seleccionados[idx].cantidad++;
        _seleccionados[idx].subtotal = _seleccionados[idx].cantidad * precio;
      } else {
        _seleccionados.add(CotizacionItem(
          cotizacionId: 0,
          tipo: tipo,
          nombre: nombre,
          precio: precio,
          cantidad: 1,
          subtotal: precio,
        ));
      }
    });
  }

  void _quitar(int idx) {
    setState(() => _seleccionados.removeAt(idx));
  }

  void _reducir(int idx) {
    setState(() {
      if (_seleccionados[idx].cantidad > 1) {
        _seleccionados[idx].cantidad--;
        _seleccionados[idx].subtotal = _seleccionados[idx].cantidad * _seleccionados[idx].precio;
      } else {
        _seleccionados.removeAt(idx);
      }
    });
  }

  Future<void> _guardar() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un servicio o producto')),
      );
      return;
    }
    final fecha = DateTime.now();
    final fechaStr = '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    final cotizacion = Cotizacion(fecha: fechaStr, total: _total, notas: _notasCtrl.text.trim());
    await DBHelper.instance.addCotizacion(cotizacion, _seleccionados);
    setState(() {
      _seleccionados = [];
      _notasCtrl.clear();
    });
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Guardado'),
          content: Text('Cotización guardada por \$${_total.toStringAsFixed(2)}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizador'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Servicios'),
            Tab(text: 'Productos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLista(_servicios.map((s) => {'nombre': s.nombre, 'precio': s.precioBase, 'tipo': 'servicio'}).toList()),
                _buildLista(_productos.map((p) => {'nombre': p.nombre, 'precio': p.precio, 'tipo': 'producto'}).toList()),
              ],
            ),
          ),
          if (_seleccionados.isNotEmpty) _buildResumen(),
        ],
      ),
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay elementos registrados', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final enLista = _seleccionados.where((s) => s.nombre == item['nombre'] && s.tipo == item['tipo']).firstOrNull;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: enLista != null ? AppTheme.primaryLight : Colors.white,
          child: ListTile(
            title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('\$${(item['precio'] as double).toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.primary)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (enLista != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: Text('x${enLista.cantidad}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 30),
                  onPressed: () => _agregar(item['nombre'], item['precio'], item['tipo']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumen() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🧾 Resumen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: _seleccionados.length,
              itemBuilder: (_, i) {
                final item = _seleccionados[i];
                return Row(
                  children: [
                    Expanded(child: Text('${item.nombre} x${item.cantidad}', style: const TextStyle(fontSize: 13))),
                    IconButton(icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.grey), onPressed: () => _reducir(i)),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () => _quitar(i)),
                    Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                );
              },
            ),
          ),
          TextField(
            controller: _notasCtrl,
            decoration: const InputDecoration(labelText: 'Notas (nombre del cliente, etc.)', isDense: true),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cotización'),
            ),
          ),
        ],
      ),
    );
  }
}