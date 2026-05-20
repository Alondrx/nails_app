import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/producto.dart';
import '../theme/app_theme.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> _productos = [];
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await DBHelper.instance.getProductos();
    setState(() => _productos = data);
  }

  void _abrirModal({Producto? producto}) {
    _nombreCtrl.text = producto?.nombre ?? '';
    _precioCtrl.text = producto?.precio.toString() ?? '';
    _unidadCtrl.text = producto?.unidad ?? 'unidad';

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
              producto == null ? 'Nuevo Producto' : 'Editar Producto',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del producto')),
            const SizedBox(height: 12),
            TextField(controller: _precioCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _unidadCtrl, decoration: const InputDecoration(labelText: 'Unidad (ml, gr, unidad...)')),
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
                  final p = Producto(
                    id: producto?.id,
                    nombre: _nombreCtrl.text.trim(),
                    precio: double.parse(_precioCtrl.text.trim()),
                    unidad: _unidadCtrl.text.trim().isEmpty ? 'unidad' : _unidadCtrl.text.trim(),
                  );
                  if (producto == null) {
                    await DBHelper.instance.addProducto(p);
                  } else {
                    await DBHelper.instance.updateProducto(p);
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
        content: const Text('¿Segura que deseas eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteProducto(id);
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
      appBar: AppBar(title: const Text('Productos')),
      body: _productos.isEmpty
          ? const Center(
              child: Text('No hay productos aún.\n¡Agrega el primero! 🌸',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _productos.length,
              itemBuilder: (_, i) {
                final p = _productos[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('\$${p.precio.toStringAsFixed(2)} / ${p.unidad}',
                        style: const TextStyle(color: AppTheme.primary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary), onPressed: () => _abrirModal(producto: p)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _eliminar(p.id!)),
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