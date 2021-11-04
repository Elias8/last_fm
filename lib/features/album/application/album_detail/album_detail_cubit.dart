import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../album.dart';

part 'album_detail_state.dart';

/// A cubit responsible for [AlbumDetail] related functionality.
@injectable
class AlbumDetailCubit extends Cubit<AlbumDetailState> {
  final AlbumRepository _albumRepository;

  AlbumDetailCubit(this._albumRepository) : super(const AlbumDetailInitial());

  /// Deletes an album from [_albumRepository].
  ///
  /// Before this method is called, the current [state] has to be
  /// [AlbumDetailLoaded]. Otherwise, calling this method does nothing.
  Future<void> deleteAlbum() async {
    if (state is AlbumDetailLoaded) {
      final response = (state as AlbumDetailLoaded).response;
      if (response is Right<AlbumDetailNetworkError, AlbumDetail>) {
        await _deleteAlbum(response.value);
      }
    }
  }

  /// Gets an album detail from the [_albumRepository] and emits
  /// [AlbumDetailLoaded] state with the albums.
  Future<void> loadAlbumDetail(AlbumDetailQuery query) async {
    emit(const AlbumDetailLoading());
    return _albumRepository
        .findAlbumDetail(query)
        .then((response) => AlbumDetailLoaded(response))
        .then(emit);
  }

  Future<void> _deleteAlbum(AlbumDetail album) {
    return _albumRepository
        .deleteAlbum(AlbumDetailQuery.fromAlbum(album))
        .then((_) => const AlbumDetailDeleted())
        .then(emit);
  }
}