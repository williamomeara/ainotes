import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_state.freezed.dart';

/// Download state for an ML model.
@freezed
sealed class DownloadState with _$DownloadState {
  const factory DownloadState.notStarted() = NotStarted;
  const factory DownloadState.downloading({required double progress}) =
      Downloading;
  const factory DownloadState.ready({required String localPath}) = Ready;
  const factory DownloadState.error({required String message}) =
      DownloadError;
}
