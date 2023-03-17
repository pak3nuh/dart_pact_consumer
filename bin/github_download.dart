
import 'dart:io';

const pactVersion = '0.1.1';

String _getDownloadLink() {
  if (Platform.isLinux) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v$pactVersion/libpact_mock_server_ffi-linux-x86_64.so.gz';
  } else if (Platform.isMacOS) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v$pactVersion/libpact_mock_server_ffi-osx-x86_64.dylib.gz';
  } else if (Platform.isWindows) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v$pactVersion/libpact_mock_server_ffi-windows-x86_64.dll.gz';
  }
  throw Exception('Unsupported platform: ${Platform.operatingSystem}');
}

final _finalPath = '${Directory.systemTemp.path}/libpact_mock_server_ffi-v$pactVersion';
final _downloadPath = '${Directory.systemTemp.path}/libpact_mock_server_ffi-v$pactVersion.gz';

Future<String> downloadFromGithub() async {
  if (await File(_finalPath).exists()) {
    print('Lib file already exists at $_finalPath');
    return _finalPath;
  }
  await _download();
  await _unzip();
  return _finalPath;
}

Future<void> _unzip() async {
  print('Decompressing file $_downloadPath');
  final bytes = await File(_downloadPath).readAsBytes();
  final decoded = gzip.decode(bytes);
  print('Writing file $_finalPath');
  final writeStream = File(_finalPath).openWrite();
  writeStream.add(decoded);
  await writeStream.close();
}

Future<void> _download() async {
  final file = File(_downloadPath);
  if (await file.exists()) {
    print('GZ file exists');
    return;
  }

  final link = _getDownloadLink();
  print('Downloading gz file: $link');
  final request = await HttpClient().getUrl(Uri.parse(link));
  final response = await request.close();
  final streamConsumer = file.openWrite();
  await response.pipe(streamConsumer);
  await streamConsumer.close();
}

Future<void> main() async {
  await downloadFromGithub();
}