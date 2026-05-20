class Servicio {
  final int? id;
  final String nombre;
  final double precioBase;
  final String descripcion;

  Servicio({
    this.id,
    required this.nombre,
    required this.precioBase,
    required this.descripcion,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'precio_base': precioBase,
        'descripcion': descripcion,
      };

  factory Servicio.fromMap(Map<String, dynamic> map) => Servicio(
        id: map['id'],
        nombre: map['nombre'],
        precioBase: map['precio_base'],
        descripcion: map['descripcion'] ?? '',
      );
}