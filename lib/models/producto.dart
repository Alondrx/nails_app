class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final String unidad;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.unidad,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'unidad': unidad,
      };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
        id: map['id'],
        nombre: map['nombre'],
        precio: map['precio'],
        unidad: map['unidad'],
      );
}