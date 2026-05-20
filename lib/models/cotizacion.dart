class CotizacionItem {
  final int? id;
  final int cotizacionId;
  final String tipo;
  final String nombre;
  final double precio;
  int cantidad;
  double subtotal;

  CotizacionItem({
    this.id,
    required this.cotizacionId,
    required this.tipo,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cotizacion_id': cotizacionId,
        'tipo': tipo,
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
        'subtotal': subtotal,
      };

  factory CotizacionItem.fromMap(Map<String, dynamic> map) => CotizacionItem(
        id: map['id'],
        cotizacionId: map['cotizacion_id'],
        tipo: map['tipo'],
        nombre: map['nombre'],
        precio: map['precio'],
        cantidad: map['cantidad'],
        subtotal: map['subtotal'],
      );
}

class Cotizacion {
  final int? id;
  final String fecha;
  final double total;
  final String notas;
  List<CotizacionItem> items;

  Cotizacion({
    this.id,
    required this.fecha,
    required this.total,
    required this.notas,
    this.items = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fecha': fecha,
        'total': total,
        'notas': notas,
      };

  factory Cotizacion.fromMap(Map<String, dynamic> map) => Cotizacion(
        id: map['id'],
        fecha: map['fecha'],
        total: map['total'],
        notas: map['notas'] ?? '',
      );
}