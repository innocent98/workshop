import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/client_home/domain/models/artisan.dart';

Artisan _artisan() => const Artisan(
  id: 'a1',
  name: 'Ada Obi',
  service: 'Plumbing',
  imageUrl: '',
  avatarUrl: '',
  offeredServices: [
    ArtisanServiceOption(id: 1, name: 'Plumbing'),
    ArtisanServiceOption(id: 2, name: 'Tiling'),
    ArtisanServiceOption(id: 3, name: 'Painting'),
  ],
);

void main() {
  test('pre-selects the service the user searched for', () {
    final artisan = _artisan().withPreferredServiceFromQuery('tiling');
    expect(artisan.initialServiceIndex(artisan.offeredServices), 1);
  });

  test('falls back to the first service when nothing matches', () {
    final artisan = _artisan().withPreferredServiceFromQuery('roofing');
    expect(artisan.preferredService, isNull);
    expect(artisan.initialServiceIndex(artisan.offeredServices), 0);
  });

  test('empty query leaves the artisan unchanged', () {
    final artisan = _artisan();
    expect(
      identical(artisan.withPreferredServiceFromQuery(' '), artisan),
      isTrue,
    );
  });
}
