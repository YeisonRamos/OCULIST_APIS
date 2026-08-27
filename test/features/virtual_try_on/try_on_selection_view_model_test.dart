import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/face_capture/domain/models/face_shape.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';
import 'package:oculist/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart';

class _ClientRepository implements ClientRepository {
  _ClientRepository(this.shape);
  final FaceShape shape;

  @override
  Future<Client> getClientById(String clientId) async => Client(
    id: clientId,
    nombres: 'Ana',
    apellidos: 'Flores',
    telefono: '70000000',
    fechaRegistro: DateTime(2026, 8, 1),
    activo: true,
    fotoFacialUrl: 'https://example.com/rostro.jpg',
    tipoRostro: shape,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FrameRepository implements FrameRepository {
  _FrameRepository(this.frames);
  final List<Frame> frames;

  @override
  Stream<List<Frame>> watchActiveFrames() => Stream.value(frames);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Frame _frame(String id, String forma, {bool disponible = true}) => Frame(
  id: id,
  codigo: 'COD-$id',
  marca: 'Marca $id',
  modelo: 'Modelo $id',
  color: 'Rojo',
  forma: forma,
  material: 'Metal',
  talla: 'M',
  disponible: disponible,
  activo: true,
  fechaRegistro: DateTime(2026, 8, 1),
);

void main() {
  test('recomienda montura rectangular para rostro redondo', () async {
    final rectangular = _frame('1', 'Rectangular');
    final round = _frame('2', 'Redonda');
    final unavailable = _frame('3', 'Cuadrada', disponible: false);
    final model = TryOnSelectionViewModel(
      clientRepository: _ClientRepository(FaceShape.round),
      frameRepository: _FrameRepository([round, unavailable, rectangular]),
      clientId: 'cliente-1',
    );

    await model.load();
    await Future<void>.delayed(Duration.zero);

    expect(model.primaryRecommendation, rectangular);
    expect(model.alternativeRecommendations, [round]);
    model.dispose();
  });

  test('recomienda montura redonda para rostro cuadrado', () async {
    final rectangular = _frame('1', 'Rectangular');
    final round = _frame('2', 'Redonda');
    final model = TryOnSelectionViewModel(
      clientRepository: _ClientRepository(FaceShape.square),
      frameRepository: _FrameRepository([rectangular, round]),
      clientId: 'cliente-1',
    );

    await model.load();
    await Future<void>.delayed(Duration.zero);

    expect(model.primaryRecommendation, round);
    model.dispose();
  });
}
