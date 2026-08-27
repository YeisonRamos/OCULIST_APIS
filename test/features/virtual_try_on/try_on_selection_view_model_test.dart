import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/features/clients/domain/models/client.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';
import 'package:oculist/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart';

class _ClientRepository implements ClientRepository {
  @override
  Future<Client> getClientById(String clientId) async {
    return Client(
      id: clientId,
      nombres: 'Ana',
      apellidos: 'Flores',
      telefono: '70000000',
      fechaRegistro: DateTime(2026, 8, 1),
      activo: true,
      fotoFacialUrl: 'https://example.com/rostro.jpg',
    );
  }

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

Frame _frame({
  required String id,
  required String marca,
  bool disponible = true,
}) {
  return Frame(
    id: id,
    codigo: 'COD-$id',
    marca: marca,
    modelo: 'Modelo $id',
    color: 'Rojo',
    forma: 'Redonda',
    material: 'Metal',
    talla: 'M',
    disponible: disponible,
    activo: true,
    fechaRegistro: DateTime(2026, 8, 1),
  );
}

void main() {
  test('muestra solo monturas disponibles y permite seleccionar', () async {
    final available = _frame(id: '1', marca: 'RayBan');
    final unavailable = _frame(id: '2', marca: 'Oculist', disponible: false);
    final viewModel = TryOnSelectionViewModel(
      clientRepository: _ClientRepository(),
      frameRepository: _FrameRepository([available, unavailable]),
      clientId: 'cliente-1',
    );

    await viewModel.load();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.client?.nombreCompleto, 'Ana Flores');
    expect(viewModel.filteredFrames, [available]);

    viewModel.selectFrame(available);
    expect(viewModel.selectedFrame, available);

    viewModel.dispose();
  });

  test('busca monturas por marca sin distinguir mayúsculas', () async {
    final rayBan = _frame(id: '1', marca: 'RayBan');
    final vogue = _frame(id: '2', marca: 'Vogue');
    final viewModel = TryOnSelectionViewModel(
      clientRepository: _ClientRepository(),
      frameRepository: _FrameRepository([rayBan, vogue]),
      clientId: 'cliente-1',
    );

    await viewModel.load();
    await Future<void>.delayed(Duration.zero);
    viewModel.search('rayban');

    expect(viewModel.filteredFrames, [rayBan]);

    viewModel.dispose();
  });
}
