import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

Future<void> main() async {
  final sourceFile = File('assets/images/tuno_logo.png');
  final sourceBytes = await sourceFile.readAsBytes();
  final originalImage = decodeImage(sourceBytes)!;

  final outputDir = Directory('web/icons');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  Future<void> createIcon({
    required String name,
    required int size,
    double logoScale = 0.6,
  }) async {
    final canvas = Image(width: size, height: size);
    fill(canvas, color: ColorRgb8(0, 0, 0));

    final logoSize = (size * logoScale).round();
    final resizedLogo = copyResize(originalImage, width: logoSize, height: logoSize);

    final x = (size - logoSize) ~/ 2;
    final y = (size - logoSize) ~/ 2;

    // drawImage is not available, use compositeImage instead
    compositeImage(canvas, resizedLogo, dstX: x, dstY: y);

    final outputFile = File('${outputDir.path}/$name');
    await outputFile.writeAsBytes(encodePng(canvas));
    print('Generated: ${outputFile.path} (${size}x${size})');
  }

  // Generate all required icons
  // favicon.png - 192x192 (standard web favicon size)
  await createIcon(name: 'favicon.png', size: 192, logoScale: 0.6);

  // Icon-192.png - 192x192
  await createIcon(name: 'Icon-192.png', size: 192, logoScale: 0.6);

  // Icon-512.png - 512x512
  await createIcon(name: 'Icon-512.png', size: 512, logoScale: 0.6);

  // Icon-maskable-192.png - 192x192 maskable (logo fits in safe zone)
  await createIcon(name: 'Icon-maskable-192.png', size: 192, logoScale: 0.6);

  // Icon-maskable-512.png - 512x512 maskable
  await createIcon(name: 'Icon-maskable-512.png', size: 512, logoScale: 0.6);

  // Also copy favicon.png to web/ root
  final faviconSource = File('web/icons/favicon.png');
  final faviconDest = File('web/favicon.png');
  await faviconSource.copy(faviconDest.path);
  print('Copied: ${faviconDest.path}');

  print('\nAll icons generated successfully!');
}