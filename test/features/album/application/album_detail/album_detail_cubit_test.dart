import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:last_fm/features/album/album.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networkx/networkx.dart';

void main() {
  group('$AlbumDetailCubit', () {
    late AlbumDetail albumDetail;
    late AlbumRepository albumRepository;
    late AlbumDetailCubit albumDetailCubit;
    const query = AlbumDetailQuery(
      albumName: 'House Of Balloons',
      artistName: 'The Weeknd',
    );

    setUp(() {
      albumDetail = _MockAlbumDetail();
      albumRepository = _MockAlbumRepository();
      albumDetailCubit = AlbumDetailCubit(albumRepository);

      when(() => albumDetail.name).thenReturn('House Of Balloons');
      when(() => albumDetail.artist)
          .thenReturn(const ArtistInfo(name: 'The Weeknd'));
    });

    tearDown(() => albumDetailCubit.close());

    group('deleteAlbum', () {
      blocTest<AlbumDetailCubit, AlbumDetailState>(
        'should emit [ '
        'AlbumDetailLoading, '
        'AlbumDetailSuccess, '
        'AlbumDetailDeleted '
        '] when album is loaded and deleted',
        setUp: () {
          when(() => albumRepository.findAlbumDetail(query))
              .thenAnswer((_) async => right(albumDetail));
          when(() => albumRepository.deleteAlbum(query))
              .thenAnswer((_) => Future.value());
        },
        build: () => albumDetailCubit,
        act: (cubit) async {
          await cubit.loadAlbumDetail(query);
          await cubit.deleteAlbum();
        },
        expect: () => [
          const AlbumDetailLoading(),
          AlbumDetailSuccess(albumDetail),
          const AlbumDetailDeleted(),
        ],
      );
    });

    group('loadAlbumDetail', () {
      blocTest<AlbumDetailCubit, AlbumDetailState>(
        'should emit [ AlbumDetailLoading, AlbumDetailFailure ] when error is '
        'returned',
        setUp: () {
          when(() => albumRepository.findAlbumDetail(query))
              .thenAnswer((_) async => left(const NetworkError.cancelled()));
        },
        build: () => albumDetailCubit,
        act: (cubit) => cubit.loadAlbumDetail(query),
        expect: () => const [
          AlbumDetailLoading(),
          AlbumDetailFailure(NetworkError.cancelled()),
        ],
      );
    });
  });
}

class _MockAlbumDetail extends Mock implements AlbumDetail {}

class _MockAlbumRepository extends Mock implements AlbumRepository {}
