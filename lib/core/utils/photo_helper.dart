import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoHelper {
  static Future<String?> pickAndSave({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/car_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);

    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final savedPath = '${photosDir.path}/${const Uuid().v4()}$ext';
    await File(picked.path).copy(savedPath);
    return savedPath;
  }

  static Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
