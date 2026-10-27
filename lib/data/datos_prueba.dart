import '../core/app_images.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/reglas_salon.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

/// Datos de prueba que se cargan en memoria al iniciar la app.
///
/// Las fechas se calculan a partir de [DateTime.now], así los datos no
/// quedan vencidos con el paso de los días.
abstract final class DatosPrueba {
  // ------------------------------------------------------------------
  // Catálogo de servicios (12, en las 5 categorías)
  // ------------------------------------------------------------------
  static const List<Servicio> servicios = [
    Servicio(
      id: '1',
      nombre: 'Corte mujer',
      categoria: CategoriaServicio.corte,
      duracionMin: 60,
      precio: 30,
      publico: Publico.mujeres,
    ),
    Servicio(
      id: '2',
      nombre: 'Corte caballero',
      categoria: CategoriaServicio.corte,
      duracionMin: 45,
      precio: 25,
      publico: Publico.hombres,
    ),
    Servicio(
      id: '3',
      nombre: 'Corte de puntas',
      categoria: CategoriaServicio.corte,
      duracionMin: 30,
      precio: 15,
      publico: Publico.unisex,
    ),
    Servicio(
      id: '4',
      nombre: 'Color completo',
      categoria: CategoriaServicio.color,
      duracionMin: 120,
      precio: 70,
      publico: Publico.mujeres,
    ),
    Servicio(
      id: '5',
      nombre: 'Retoque de raíz',
      categoria: CategoriaServicio.color,
      duracionMin: 60,
      precio: 35,
      publico: Publico.mujeres,
    ),
    Servicio(
      id: '6',
      nombre: 'Tinte caballero',
      categoria: CategoriaServicio.color,
      duracionMin: 45,
      precio: 30,
      publico: Publico.hombres,
    ),
    Servicio(
      id: '7',
      nombre: 'Barba',
      categoria: CategoriaServicio.barba,
      duracionMin: 45,
      precio: 20,
      publico: Publico.hombres,
    ),
    Servicio(
      id: '8',
      nombre: 'Arreglo de barba',
      categoria: CategoriaServicio.barba,
      duracionMin: 30,
      precio: 12,
      publico: Publico.hombres,
    ),
    Servicio(
      id: '9',
      nombre: 'Brushing',
      categoria: CategoriaServicio.peinado,
      duracionMin: 30,
      precio: 20,
      publico: Publico.mujeres,
    ),
    Servicio(
      id: '10',
      nombre: 'Peinado evento',
      categoria: CategoriaServicio.peinado,
      duracionMin: 60,
      precio: 40,
      publico: Publico.unisex,
    ),
    Servicio(
      id: '11',
      nombre: 'Hidratación',
      categoria: CategoriaServicio.tratamiento,
      duracionMin: 45,
      precio: 28,
      publico: Publico.unisex,
    ),
    Servicio(
      id: '12',
      nombre: 'Tratamiento anticaída',
      categoria: CategoriaServicio.tratamiento,
      duracionMin: 45,
      precio: 32,
      publico: Publico.unisex,
    ),
  ];

  // ------------------------------------------------------------------
  // Estilistas (5): uno solo de mujeres, uno solo de hombres, uno de ambos
  // ------------------------------------------------------------------
  static final List<Estilista> estilistas = [
    Estilista(
      id: '1',
      nombre: 'Marta Salazar',
      avatar: AppImages.avatares[0],
      servicioIds: ['1', '4', '5', '9'],
    ),
    Estilista(
      id: '2',
      nombre: 'Pedro Vega',
      avatar: AppImages.avatares[1],
      servicioIds: ['2', '6', '7', '8'],
    ),
    Estilista(
      id: '3',
      nombre: 'Lucía Torres',
      avatar: AppImages.avatares[2],
      servicioIds: ['1', '2', '3', '10', '11', '12'],
    ),
    Estilista(
      id: '4',
      nombre: 'Rafael Núñez',
      avatar: AppImages.avatares[3],
      servicioIds: ['2', '3', '7', '8'],
    ),
    Estilista(
      id: '5',
      nombre: 'Elena Ríos',
      avatar: AppImages.avatares[4],
      servicioIds: ['3', '9', '10', '11', '12'],
    ),
  ];

  // ------------------------------------------------------------------
  // Clientes (10): 5 mujeres y 5 hombres
  // ------------------------------------------------------------------
  static List<Cliente> clientes(DateTime ahora) {
    DateTime hace(int dias) => ahora.subtract(Duration(days: dias));
    return [
      Cliente(
        id: '1',
        nombre: 'Laura Gómez',
        telefono: '52111222',
        genero: Genero.mujer,
        correo: 'laura.gomez@correo.cu',
        fechaRegistro: hace(420),
      ),
      Cliente(
        id: '2',
        nombre: 'Carlos Ruiz',
        telefono: '52345678',
        genero: Genero.hombre,
        correo: 'carlos.ruiz@correo.cu',
        fechaRegistro: hace(390),
      ),
      Cliente(
        id: '3',
        nombre: 'Ana Martín',
        telefono: '53220140',
        genero: Genero.mujer,
        correo: null,
        fechaRegistro: hace(300),
      ),
      Cliente(
        id: '4',
        nombre: 'Diego Pérez',
        telefono: '55908771',
        genero: Genero.hombre,
        correo: null,
        fechaRegistro: hace(260),
      ),
      Cliente(
        id: '5',
        nombre: 'Sofía Díaz',
        telefono: '54667310',
        genero: Genero.mujer,
        correo: 'sofia.diaz@correo.cu',
        fechaRegistro: hace(210),
      ),
      Cliente(
        id: '6',
        nombre: 'Javier Soto',
        telefono: '52774009',
        genero: Genero.hombre,
        correo: null,
        fechaRegistro: hace(150),
      ),
      Cliente(
        id: '7',
        nombre: 'Marta Peña',
        telefono: '53441902',
        genero: Genero.mujer,
        correo: 'marta.pena@correo.cu',
        fechaRegistro: hace(90),
      ),
      Cliente(
        id: '8',
        nombre: 'Valeria Ortiz',
        telefono: '55321764',
        genero: Genero.mujer,
        correo: null,
        fechaRegistro: hace(40),
      ),
      Cliente(
        id: '9',
        nombre: 'Pablo Herrera',
        telefono: '53889120',
        genero: Genero.hombre,
        correo: 'pablo.herrera@correo.cu',
        fechaRegistro: hace(22),
      ),
      Cliente(
        id: '10',
        nombre: 'Andrés Lima',
        telefono: '52998455',
        genero: Genero.hombre,
        correo: null,
        fechaRegistro: hace(6),
      ),
    ];
  }

  // ------------------------------------------------------------------
  // Turnos (16) repartidos en 7 días laborables alrededor de hoy
  // ------------------------------------------------------------------

  /// El día de referencia: hoy, o el siguiente día abierto si hoy es
  /// domingo (el salón está cerrado).
  static DateTime _ancla(DateTime ahora) {
    var d = ReglasSalon.soloFecha(ahora);
    while (!ReglasSalon.estaAbierto(d)) {
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return d;
  }

  /// Avanza o retrocede [pasos] días laborables desde [ancla]
  /// (se saltan los domingos).
  static DateTime _diaLaborable(DateTime ancla, int pasos) {
    var d = ancla;
    final sentido = pasos < 0 ? -1 : 1;
    var restantes = pasos.abs();
    while (restantes > 0) {
      d = DateTime(d.year, d.month, d.day + sentido);
      if (ReglasSalon.estaAbierto(d)) restantes--;
    }
    return d;
  }

  static Servicio _servicio(String id) =>
      servicios.firstWhere((s) => s.id == id);

  static List<Turno> turnos(DateTime ahora) {
    final ancla = _ancla(ahora);

    Turno crear({
      required String id,
      required int pasos,
      required int hora,
      int minuto = 0,
      required String clienteId,
      required String estilistaId,
      required List<String> servicioIds,
      String? notas,
      bool cancelado = false,
      required int creadoHace,
      required int modificadoHace,
    }) {
      final dia = _diaLaborable(ancla, pasos);
      final inicio = DateTime(dia.year, dia.month, dia.day, hora, minuto);
      final lista = servicioIds.map(_servicio).toList();
      final duracion = lista.fold<int>(0, (suma, s) => suma + s.duracionMin);
      final fin = inicio.add(Duration(minutes: duracion));

      // Los pasados están completados o cancelados; los futuros, programados.
      final EstadoTurno estado;
      if (cancelado) {
        estado = EstadoTurno.cancelado;
      } else if (fin.isAfter(ahora)) {
        estado = EstadoTurno.programado;
      } else {
        estado = EstadoTurno.completado;
      }

      return Turno(
        id: id,
        clienteId: clienteId,
        estilistaId: estilistaId,
        servicios: lista,
        inicio: inicio,
        notas: notas,
        estado: estado,
        creadoEn: ahora.subtract(Duration(days: creadoHace)),
        modificadoEn: ahora.subtract(Duration(days: modificadoHace)),
      );
    }

    return [
      crear(
        id: '1',
        pasos: -3,
        hora: 9,
        minuto: 0,
        clienteId: '1',
        estilistaId: '1',
        servicioIds: ['1'],
        notas: 'Quiere el largo a la altura de los hombros.',
        creadoHace: 10,
        modificadoHace: 3,
      ),
      crear(
        id: '2',
        pasos: -3,
        hora: 10,
        minuto: 0,
        clienteId: '2',
        estilistaId: '2',
        servicioIds: ['2', '7'],
        notas: null,
        creadoHace: 9,
        modificadoHace: 3,
      ),
      crear(
        id: '3',
        pasos: -2,
        hora: 11,
        minuto: 0,
        clienteId: '3',
        estilistaId: '1',
        servicioIds: ['4'],
        notas: 'Tono castaño claro. Trajo una foto de referencia.',
        creadoHace: 7,
        modificadoHace: 2,
      ),
      crear(
        id: '4',
        pasos: -2,
        hora: 15,
        minuto: 0,
        clienteId: '4',
        estilistaId: '2',
        servicioIds: ['8'],
        notas: 'Canceló por motivos de trabajo.',
        cancelado: true,
        creadoHace: 6,
        modificadoHace: 3,
      ),
      crear(
        id: '5',
        pasos: -1,
        hora: 10,
        minuto: 0,
        clienteId: '5',
        estilistaId: '3',
        servicioIds: ['12', '1', '11'],
        notas: 'Quiere cuidar el cabello antes de cortarlo.',
        creadoHace: 5,
        modificadoHace: 1,
      ),
      crear(
        id: '6',
        pasos: -1,
        hora: 16,
        minuto: 0,
        clienteId: '7',
        estilistaId: '5',
        servicioIds: ['9'],
        notas: 'Reprogramar para la próxima semana.',
        cancelado: true,
        creadoHace: 4,
        modificadoHace: 2,
      ),
      crear(
        id: '7',
        pasos: 0,
        hora: 9,
        minuto: 30,
        clienteId: '8',
        estilistaId: '1',
        servicioIds: ['5', '9'],
        notas: 'Primera visita al salón.',
        creadoHace: 3,
        modificadoHace: 3,
      ),
      crear(
        id: '8',
        pasos: 0,
        hora: 11,
        minuto: 0,
        clienteId: '9',
        estilistaId: '2',
        servicioIds: ['2', '7'],
        notas: 'Prefiere la máquina en el número 2 a los lados.',
        creadoHace: 5,
        modificadoHace: 5,
      ),
      crear(
        id: '9',
        pasos: 0,
        hora: 14,
        minuto: 0,
        clienteId: '3',
        estilistaId: '3',
        servicioIds: ['10'],
        notas: 'Peinado para una boda el fin de semana.',
        creadoHace: 2,
        modificadoHace: 1,
      ),
      crear(
        id: '10',
        pasos: 0,
        hora: 16,
        minuto: 30,
        clienteId: '10',
        estilistaId: '2',
        servicioIds: ['6', '8'],
        notas: null,
        creadoHace: 4,
        modificadoHace: 4,
      ),
      crear(
        id: '11',
        pasos: 1,
        hora: 9,
        minuto: 0,
        clienteId: '1',
        estilistaId: '1',
        servicioIds: ['4'],
        notas: _notaLarga,
        creadoHace: 6,
        modificadoHace: 2,
      ),
      crear(
        id: '12',
        pasos: 1,
        hora: 12,
        minuto: 0,
        clienteId: '4',
        estilistaId: '4',
        servicioIds: ['2', '8'],
        notas: null,
        creadoHace: 3,
        modificadoHace: 3,
      ),
      crear(
        id: '13',
        pasos: 2,
        hora: 10,
        minuto: 0,
        clienteId: '5',
        estilistaId: '5',
        servicioIds: ['9', '11'],
        notas: 'Llega siempre diez minutos antes.',
        creadoHace: 2,
        modificadoHace: 2,
      ),
      crear(
        id: '14',
        pasos: 2,
        hora: 17,
        minuto: 0,
        clienteId: '2',
        estilistaId: '4',
        servicioIds: ['7', '2'],
        notas: 'Prefiere la máquina en el número 2 a los lados.',
        creadoHace: 4,
        modificadoHace: 1,
      ),
      crear(
        id: '15',
        pasos: 3,
        hora: 10,
        minuto: 30,
        clienteId: '7',
        estilistaId: '3',
        servicioIds: ['3', '11'],
        notas: 'Quiere cuidar el cabello después del verano.',
        creadoHace: 1,
        modificadoHace: 1,
      ),
      crear(
        id: '16',
        pasos: 3,
        hora: 17,
        minuto: 0,
        clienteId: '8',
        estilistaId: '1',
        servicioIds: ['4'],
        notas: 'Último turno del día, ya confirmó asistencia.',
        creadoHace: 3,
        modificadoHace: 0,
      ),
    ];
  }

  /// Nota de más de 300 caracteres, para probar el área con scroll.
  static const String _notaLarga =
      'La clienta es alérgica al amoníaco, así que hay que usar tintes sin '
      'amoníaco y hacer antes una prueba de alergia en la piel, detrás de la '
      'oreja. Quiere pasar de castaño oscuro a un tono más claro, tipo '
      'caramelo, sin dañar demasiado el cabello. Trae fotos de referencia en '
      'el teléfono. Prefiere que le laven el cabello con agua tibia porque '
      'tiene el cuero cabelludo sensible. Avisó que llegará con diez minutos '
      'de retraso y pidió que no la esperen para empezar la mezcla del color.';
}
