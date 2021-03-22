import 'dart:io';
import 'package:path/path.dart' as path;

import '../errors.dart';

class HTModuleInfo {
  final String fileName;
  final String content;
  HTModuleInfo(this.fileName, this.content);
}

abstract class HTImportHandler {
  Future<HTModuleInfo> import(String key, [String? curFileName]);
}

class DefaultImportHandler implements HTImportHandler {
  late final String workingDirectory;

  final imported = <String>[];

  DefaultImportHandler({String workingDirectory = 'script/'}) {
    final dir = Directory(workingDirectory);
    this.workingDirectory = dir.absolute.path;
  }

  @override
  Future<HTModuleInfo> import(String key, [String? curFileName]) async {
    var fileName = key;
    try {
      late final String filePath;
      if (curFileName != null) {
        filePath = path.dirname(curFileName);
      } else {
        filePath = workingDirectory;
      }

      fileName = path.join(filePath, key);

      var content = '';
      if (!imported.contains(fileName)) {
        imported.add(fileName);
        content = await File(fileName).readAsString();
      }
      return HTModuleInfo(fileName, content);
    } catch (e) {
      throw (HTImportError(e.toString(), fileName));
    }
  }
}
