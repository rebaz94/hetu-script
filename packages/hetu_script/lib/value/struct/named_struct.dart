import '../../source/source.dart';
import '../../declaration/declaration.dart';
import '../../declaration/namespace/namespace.dart';
import 'struct.dart';
import '../../error/error.dart';
import '../../grammar/lexicon.dart';
import '../../grammar/semantic.dart';
import '../../interpreter/interpreter.dart';
import '../../interpreter/compiler.dart' show GotoInfo;
import '../function/function.dart';

/// Unlike class and function, the declaration of a struct is a value
/// and struct object does not extends from this.
class HTNamedStruct extends HTDeclaration with HetuRef, GotoInfo {
  final String _id;

  @override
  String get id => _id;

  final String? prototypeId;

  HTStruct? _self;

  final int? staticDefinitionIp;

  HTNamedStruct(
    this._id,
    Hetu interpreter,
    String filename,
    String libraryName,
    HTNamespace closure, {
    this.prototypeId,
    HTSource? source,
    bool isTopLevel = false,
    this.staticDefinitionIp,
    int? definitionIp,
  }) : super(
            id: _id, closure: closure, source: source, isTopLevel: isTopLevel) {
    this.interpreter = interpreter;
    this.filename = filename;
    this.libraryName = libraryName;
    this.definitionIp = definitionIp;
  }

  HTStruct createObject({
    List<dynamic> positionalArgs = const [],
    Map<String, dynamic> namedArgs = const {},
  }) {
    if (!isResolved) {
      throw HTError.unresolvedNamedStruct(id);
    }
    HTStruct structObj = _self!.clone();
    if (structObj.owns(SemanticNames.constructor)) {
      final constructor =
          structObj.memberGet(SemanticNames.constructor) as HTFunction;
      constructor.call(positionalArgs: positionalArgs, namedArgs: namedArgs);
    }
    // TODO: even if there's none constructor, you can still create a struct through the named arguments
    return structObj;
  }

  @override
  void resolve() {
    super.resolve();
    HTStruct static = interpreter.execute(
        filename: filename,
        libraryName: libraryName,
        ip: staticDefinitionIp!,
        namespace: closure);
    if (closure != null) {
      if (prototypeId != null) {
        static.prototype = closure!.memberGet(prototypeId!);
      } else if (id != HTLexicon.prototype) {
        static.prototype = closure!.memberGet(HTLexicon.prototype);
      }
    }
    HTStruct self = interpreter.execute(
        filename: filename,
        libraryName: libraryName,
        ip: definitionIp!,
        namespace: closure);
    self.prototype = static;
    self.definition = this;
    _self = self;
  }

  @override
  HTStruct get value {
    if (isResolved) {
      return _self!;
    } else {
      throw HTError.unresolvedNamedStruct(id);
    }
  }

  @override
  HTNamedStruct clone() => HTNamedStruct(
        id,
        interpreter,
        filename,
        libraryName,
        closure!,
        source: source,
        prototypeId: prototypeId,
        isTopLevel: isTopLevel,
        staticDefinitionIp: staticDefinitionIp,
        definitionIp: definitionIp,
      );
}
