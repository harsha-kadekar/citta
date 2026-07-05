import 'package:file_picker/file_picker.dart';

/// Opens the OS file picker restricted to audio files and returns the
/// selected file as a `custom:<path>` selection string — the same
/// convention used for bell sounds — or `null` if the user cancelled or the
/// picker returned no usable path.
Future<String?> pickCustomAudioSelection() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.audio);
  final path = result?.files.single.path;
  return path == null ? null : 'custom:$path';
}
