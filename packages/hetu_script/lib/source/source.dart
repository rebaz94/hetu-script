import 'dart:math' as math;

import 'package:path/path.dart' as path;

// import '../grammar/lexicon.dart';
import '../grammar/constant.dart';
import 'line_info.dart';
import '../resource/resource.dart';
import '../shared/crc32b.dart';

/// A piece of code, with extra informations like:
/// [fullName], [type], [lineInfo], etc.
class HTSource {
  static const _anonymousScriptNameLengthLimit = 18;

  String get basename => path.basename(_fullName);

  late final String _fullName;

  String get fullName => _fullName;

  HTResourceType type;

  String _content;
  String get content => _content;
  set content(String value) {
    _content = value;
    _lineInfo = LineInfo.fromContent(content);
  }

  LineInfo _lineInfo;
  LineInfo get lineInfo => _lineInfo;

  String? _crc;

  @override
  bool operator ==(Object other) =>
      other is HTSource ? hashCode == other.hashCode : false;

  @override
  int get hashCode => _crc != null ? _crc.hashCode : content.hashCode;

  HTSource(
    String content, {
    String? fullName,
    this.type = HTResourceType.hetuModule,
    bool hashContent = false,
  })  : _content = content,
        _lineInfo = LineInfo.fromContent(content) {
    if (fullName != null) {
      _fullName = fullName;
    } else {
      final hash = crcString(content);
      final nameBuilder = StringBuffer();
      nameBuilder.write('${InternalIdentifier.anonymousScript}_$hash: ');
      var firstLine =
          content.trimLeft().replaceAll(RegExp(r'\s+'), ' ').trimRight();
      nameBuilder.write(firstLine.substring(
          0, math.min(_anonymousScriptNameLengthLimit, firstLine.length)));
      if (firstLine.length > _anonymousScriptNameLengthLimit) {
        nameBuilder.write('...');
      }
      _fullName = nameBuilder.toString();
    }

    if (hashContent) {
      _crc = crcString(content);
    }
  }
}

/// A value, however it can be imported like a source.
/// Typically a json file, which is a [HTStruct] value in Hetu Script.
class HTJSONSource {
  final String id;
  final String moduleName;
  final dynamic value;

  const HTJSONSource(
      {required this.id, required this.moduleName, required this.value});
}
