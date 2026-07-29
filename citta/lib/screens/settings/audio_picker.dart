import 'package:file_picker/file_picker.dart';
import '../../models/audio_source.dart';

/// Opens the OS file picker restricted to audio files and returns the
/// selected file as a custom [AudioSource], or `null` if the user cancelled
/// or the picker returned no usable path.
Future<AudioSource?> pickCustomAudioSelection() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.audio);
  final path = result?.files.single.path;
  return path == null ? null : AudioSource.custom(path);
}
