import 'package:caribe_food/models/receta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crearId convierte títulos en identificadores', () {
    expect(crearId('Arroz con coco'), 'arroz-con-coco');
    expect(crearId('Carimañola'), 'carimanola');
  });

  test('normalizar quita tildes', () {
    expect(normalizar('Ñame Bocachico'), 'name bocachico');
  });
}
