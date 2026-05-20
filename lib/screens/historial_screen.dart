import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cotizacion.dart';
import '../theme/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Cotizacion> _cotizaciones = [];
  int? _expandida;
  List<CotizacionItem> _items = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await DBHelper.instance.getCotizaciones();
    setState(() => _cotizaciones = data);
  }

  Future<void> _verDetalle(int id) async {
    if (_expandida == id) {
      setState(() => _expandida = null);
      return;
    }
    final items = await DBHelper.instance.getCotizacionItems(id);
    setState(() {
      _expandida = id;
      _items = items;
    });
  }

  void _eliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Eliminar esta cotización?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteCotizacion(id);
              if (mounted) Navigator.pop(context);
              _cargar();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: _cotizaciones.isEmpty
          ? const Center(
              child: Text('No hay cotizaciones guardadas aún 📋',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cotizaciones.length,
              itemBuilder: (_, i) {
                final c = _cotizaciones[i];
                final expandida = _expandida == c.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => _verDetalle(c.id!),
                        title: Text(c.fecha, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: c.notas.isNotEmpty
                            ? Text(c.notas, style: const TextStyle(color: AppTheme.primary))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${c.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            Icon(expandida ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                          ],
                        ),
                      ),
                      if (expandida) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: _items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${item.nombre} x${item.cantidad}',
                                      style: const TextStyle(fontSize: 13))),
                                  Text('\$${item.subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      TextButton.icon(
                        onPressed: () => _eliminar(c.id!),
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}