import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/producto.dart';
import '../models/servicio.dart';
import '../models/cotizacion.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nails_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        unidad TEXT DEFAULT 'unidad'
      )
    ''');
    await db.execute('''
      CREATE TABLE servicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio_base REAL NOT NULL,
        descripcion TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cotizaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        notas TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cotizacion_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cotizacion_id INTEGER,
        tipo TEXT,
        nombre TEXT,
        precio REAL,
        cantidad INTEGER,
        subtotal REAL,
        FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones(id)
      )
    ''');
  }

  // PRODUCTOS
  Future<List<Producto>> getProductos() async {
    final db = await database;
    final result = await db.query('productos', orderBy: 'nombre');
    return result.map((e) => Producto.fromMap(e)).toList();
  }

  Future<int> addProducto(Producto p) async {
    final db = await database;
    return await db.insert('productos', p.toMap()..remove('id'));
  }

  Future<int> updateProducto(Producto p) async {
    final db = await database;
    return await db.update('productos', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // SERVICIOS
  Future<List<Servicio>> getServicios() async {
    final db = await database;
    final result = await db.query('servicios', orderBy: 'nombre');
    return result.map((e) => Servicio.fromMap(e)).toList();
  }

  Future<int> addServicio(Servicio s) async {
    final db = await database;
    return await db.insert('servicios', s.toMap()..remove('id'));
  }

  Future<int> updateServicio(Servicio s) async {
    final db = await database;
    return await db.update('servicios', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<int> deleteServicio(int id) async {
    final db = await database;
    return await db.delete('servicios', where: 'id = ?', whereArgs: [id]);
  }

  // COTIZACIONES
  Future<List<Cotizacion>> getCotizaciones() async {
    final db = await database;
    final result = await db.query('cotizaciones', orderBy: 'fecha DESC');
    return result.map((e) => Cotizacion.fromMap(e)).toList();
  }

  Future<int> addCotizacion(Cotizacion c, List<CotizacionItem> items) async {
    final db = await database;
    final id = await db.insert('cotizaciones', c.toMap()..remove('id'));
    for (final item in items) {
      await db.insert('cotizacion_items', {
        ...item.toMap()..remove('id'),
        'cotizacion_id': id,
      });
    }
    return id;
  }

  Future<List<CotizacionItem>> getCotizacionItems(int cotizacionId) async {
    final db = await database;
    final result = await db.query(
      'cotizacion_items',
      where: 'cotizacion_id = ?',
      whereArgs: [cotizacionId],
    );
    return result.map((e) => CotizacionItem.fromMap(e)).toList();
  }

  Future<void> deleteCotizacion(int id) async {
    final db = await database;
    await db.delete('cotizacion_items', where: 'cotizacion_id = ?', whereArgs: [id]);
    await db.delete('cotizaciones', where: 'id = ?', whereArgs: [id]);
  }
}