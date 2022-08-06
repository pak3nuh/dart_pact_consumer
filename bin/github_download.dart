
import 'dart:io';

String _getDownloadLink() {
  if (Platform.isLinux) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v0.0.17/libpact_mock_server_ffi-linux-x86_64.so.gz';
  } else if (Platform.isMacOS) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v0.0.17/libpact_mock_server_ffi-osx-x86_64.dylib.gz';
  } else if (Platform.isWindows) {
    return 'https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v0.0.17/libpact_mock_server_ffi-windows-x86_64.dll.gz';
  }
  throw Exception('Unsupported platform: ${Platform.operatingSystem}');
}

final _finalPath = Directory.systemTemp.path + '/libpact_mock_server_ffi-v0.0.17';
final _downloadPath = Directory.systemTemp.path + '/libpact_mock_server_ffi-v0.0.17.gz';

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
  var bytes = await File(_downloadPath).readAsBytes();
  var decoded = gzip.decode(bytes);
  var writeStream = File(_finalPath).openWrite();
  writeStream.add(decoded);
  await writeStream.close();
}

Future<void> _download() async {
  var file = File(_downloadPath);
  if (await file.exists()) {
    print('GZ file exists');
    return;
  }

  var link = _getDownloadLink();
  print('Downloading gz file: $link');
  var request = await HttpClient().getUrl(Uri.parse(link));
  var response = await request.close();
  var streamConsumer = file.openWrite();
  await response.pipe(streamConsumer);
  await streamConsumer.close();
}

Future<void> main() async {
  await downloadFromGithub();
}