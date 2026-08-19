import 'dart:typed_data';
import 'audio_decoding_service.dart';
import 'decoded_audio.dart';

/// Pure-Dart WAV PCM decoder implementation.
///
/// Supports:
/// - RIFF/WAVE format
/// - PCM signed 16-bit little-endian (format tag 1)
/// - Mono and stereo (stereo is downmixed to mono)
/// - Sample rates: 8000-192000 Hz
///
/// Rejects:
/// - Non-PCM formats (compressed WAV, ADPCM, IEEE float, etc.)
/// - Unsupported bit depths (8-bit, 24-bit, 32-bit)
/// - Malformed or truncated files
class WavPcmDecoder implements AudioDecodingService {
  static const _riffId = 0x46464952; // 'RIFF' little-endian
  static const _waveId = 0x45564157; // 'WAVE' little-endian
  static const _fmtId = 0x20746D66; // 'fmt ' little-endian
  static const _dataId = 0x61746164; // 'data' little-endian
  static const _pcmFormatTag = 1;

  @override
  bool canDecode(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final riff = _readUint32LE(bytes, 0);
    final wave = _readUint32LE(bytes, 8);
    return riff == _riffId && wave == _waveId;
  }

  @override
  DecodedAudio decode(Uint8List bytes) {
    if (!canDecode(bytes)) {
      throw const AudioDecodingException('Invalid RIFF/WAVE header');
    }

    int offset = 12; // Skip RIFF header (12 bytes)
    int? sampleRate;
    int? channels;
    int? bitsPerSample;
    int? blockAlign;
    int? audioFormat;
    int dataChunkOffset = -1;
    int dataChunkSize = 0;

    // Parse chunks
    while (offset + 8 <= bytes.length) {
      final chunkId = _readUint32LE(bytes, offset);
      final chunkSize = _readUint32LE(bytes, offset + 4);
      final chunkDataOffset = offset + 8;

      if (chunkDataOffset + chunkSize > bytes.length) {
        throw const AudioDecodingException('Truncated chunk data');
      }

      switch (chunkId) {
        case _fmtId:
          if (chunkSize < 16) {
            throw const AudioDecodingException('fmt chunk too small');
          }
          audioFormat = _readUint16LE(bytes, chunkDataOffset);
          channels = _readUint16LE(bytes, chunkDataOffset + 2);
          sampleRate = _readUint32LE(bytes, chunkDataOffset + 4);
          blockAlign = _readUint16LE(bytes, chunkDataOffset + 12);
          bitsPerSample = _readUint16LE(bytes, chunkDataOffset + 14);
          break;

        case _dataId:
          dataChunkOffset = chunkDataOffset;
          dataChunkSize = chunkSize;
          break;

        default:
          // Skip unknown chunks
          break;
      }

      // Move to next chunk (chunk size is padded to even)
      final paddedSize = (chunkSize + 1) & ~1;
      offset = chunkDataOffset + paddedSize;
    }

    // Validate required chunks found
    if (audioFormat == null ||
        sampleRate == null ||
        channels == null ||
        bitsPerSample == null) {
      throw const AudioDecodingException('Missing fmt chunk');
    }
    if (dataChunkOffset < 0) {
      throw const AudioDecodingException('Missing data chunk');
    }

    // Validate format
    if (audioFormat != _pcmFormatTag) {
      throw AudioDecodingException(
        'Unsupported WAV encoding: format tag $audioFormat (only PCM=1 supported)',
      );
    }

    if (bitsPerSample != 16) {
      throw AudioDecodingException(
        'Unsupported bit depth: $bitsPerSample-bit (only 16-bit supported)',
      );
    }

    if (channels != 1 && channels != 2) {
      throw AudioDecodingException(
        'Unsupported channel count: $channels (only mono or stereo supported)',
      );
    }

    if (sampleRate < 8000 || sampleRate > 192000) {
      throw AudioDecodingException(
        'Unsupported sample rate: $sampleRate Hz (must be 8000-192000)',
      );
    }

    // Validate block align
    final expectedBlockAlign = channels * (bitsPerSample ~/ 8);
    if (blockAlign != expectedBlockAlign) {
      throw AudioDecodingException(
        'Invalid block align: expected $expectedBlockAlign, got $blockAlign',
      );
    }

    // Validate data chunk size
    if (dataChunkSize == 0) {
      // Empty audio data - return empty decoded audio
      return DecodedAudio(
        samples: Float32List(0),
        sampleRate: sampleRate,
        channels: 1,
        duration: Duration.zero,
      );
    }

    if (dataChunkSize % expectedBlockAlign != 0) {
      throw const AudioDecodingException(
        'Data chunk size not aligned to block size',
      );
    }

    // Decode samples
    final frameCount = dataChunkSize ~/ expectedBlockAlign;
    final samples = Float32List(frameCount);

    int srcOffset = dataChunkOffset;
    for (int i = 0; i < frameCount; i++) {
      // Read left channel (or only channel for mono)
      final leftSample = _readInt16LE(bytes, srcOffset);
      srcOffset += 2;

      double sample = leftSample / 32768.0; // Normalize to [-1.0, 1.0]

      // If stereo, read right channel and average (downmix)
      if (channels == 2) {
        final rightSample = _readInt16LE(bytes, srcOffset);
        srcOffset += 2;
        sample = (sample + rightSample / 32768.0) * 0.5;
      }

      // Clamp to [-1.0, 1.0] for safety
      if (sample > 1.0) sample = 1.0;
      if (sample < -1.0) sample = -1.0;

      samples[i] = sample;
    }

    final duration = Duration(
      microseconds: ((frameCount / sampleRate) * 1_000_000).round(),
    );

    return DecodedAudio(
      samples: samples,
      sampleRate: sampleRate,
      channels: 1, // Always mono output
      duration: duration,
    );
  }

  // Little-endian readers
  static int _readUint16LE(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8);
  }

  static int _readUint32LE(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }

  static int _readInt16LE(Uint8List bytes, int offset) {
    final value = _readUint16LE(bytes, offset);
    return value >= 0x8000 ? value - 0x10000 : value;
  }
}
