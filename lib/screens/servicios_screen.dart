import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/servicio.dart';
import '../theme/app_theme.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  List<Servicio> _servicios = [];
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await DBHelper.instance.getServicios();
    setState(() => _servicios = data);
  }

  void _abrirModal({Servicio? servicio}) {
    _nombreCtrl.text = servicio?.nombre ?? '';
    _precioCtrl.text = servicio?.precioBase.toString() ?? '';
    _descripcionCtrl.text = servicio?.descripcion ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              servicio == null ? 'Nuevo Servicio' : 'Editar Servicio',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del servicio')),
            const SizedBox(height: 12),
            TextField(controller: _precioCtrl, decoration: const InputDecoration(labelText: 'Precio base'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _descripcionCtrl, decoration: const InputDecoration(labelText: 'Descripción (opcional)'), maxLines: 2),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nombreCtrl.text.trim().isEmpty || _precioCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nombre y precio son obligatorios')),
                    );
                    return;
                  }
                  final s = Servicio(
                    id: servicio?.id,
                    nombre: _nombreCtrl.text.trim(),
                    precioBase: double.parse(_precioCtrl.text.trim()),
                    descripcion: _descripcionCtrl.text.trim(),
                  );
                  if (servicio == null) {
                    await DBHelper.instance.addServicio(s);
                  } else {
                    await DBHelper.instance.updateServicio(s);
                  }
                  if (mounted) Navigator.pop(context);
                  _cargar();
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Segura que deseas eliminar este servicio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteServicio(id);
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
      appBar: AppBar(title: const Text('Servicios')),
      body: _servicios.isEmpty
          ? const Center(
              child: Text('No hay servicios aún.\n¡Agrega el primero! 💅',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _servicios.length,
              itemBuilder: (_, i) {
                final s = _servicios[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${s.precioBase.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary)),
                        if (s.descripcion.isNotEmpty)
                          Text(s.descripcion, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary), onPressed: () => _abrirModal(servicio: s)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _eliminar(s.id!)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModal(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}