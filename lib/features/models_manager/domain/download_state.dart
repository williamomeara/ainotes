import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_state.freezed.dart';

/// Download state for an ML model.
@freezed
sealed class DownloadState with _$DownloadState {
  const factory DownloadState.notStarted() = NotStarted;
  const factory DownloadState.downloading({
    required double progress,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    DateTime? startTime,
  }) = Downloading;
  const factory DownloadState.paused({required double progress}) = Paused;
  const factory DownloadState.ready({required String localPath}) = Ready;
  const factory DownloadState.error({required String message}) =
      DownloadError;
}

/// Extension on [Downloading] for speed/ETA computation.
extension DownloadingExt on Downloading {
  double get speedBytesPerSec {
    if (startTime == null || downloadedBytes <= 0) return 0;
    final elapsed = DateTime.now().difference(startTime!).inMilliseconds;
    if (elapsed <= 0) return 0;
    return downloadedBytes / (elapsed / 1000);
  }

  String get speedFormatted {
    final speed = speedBytesPerSec;
    if (speed <= 0) return '';
    if (speed >= 1024 * 1024) {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    if (speed >= 1024) {
      return '${(speed / 1024).toStringAsFixed(0)} KB/s';
    }
    return '${speed.toStringAsFixed(0)} B/s';
  }

  String get etaFormatted {
    final speed = speedBytesPerSec;
    if (speed <= 0 || totalBytes <= 0) return '';
    final remaining = totalBytes - downloadedBytes;
    if (remaining <= 0) return '';
    final seconds = (remaining / speed).round();
    if (seconds < 60) return '${seconds}s left';
    if (seconds < 3600) return '${(seconds / 60).round()}m left';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m}m left';
  }

  String get statusText {
    final parts = <String>['${(progress * 100).round()}%'];
    final speed = speedFormatted;
    if (speed.isNotEmpty) parts.add(speed);
    final eta = etaFormatted;
    if (eta.isNotEmpty) parts.add(eta);
    return parts.join(' \u00b7 ');
  }
}
