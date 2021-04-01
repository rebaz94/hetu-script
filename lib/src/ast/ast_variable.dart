import '../variable.dart';
import 'ast.dart';
import '../type.dart';
import 'ast_interpreter.dart';
import '../errors.dart';

class HTAstVariable extends HTVariable with AstInterpreterRef {
  final bool isDynamic;

  @override
  final bool isImmutable;

  var _isInitializing = false;

  HTTypeId? _declType;
  HTTypeId get declType => _declType!;

  ASTNode? initializer;

  HTAstVariable(String id, HTAstInterpreter interpreter,
      {dynamic value,
      HTTypeId? declType,
      this.initializer,
      Function? getter,
      Function? setter,
      this.isDynamic = false,
      bool isExtern = false,
      this.isImmutable = false,
      bool isMember = false,
      bool isStatic = false})
      : super(id,
            value: value, getter: getter, setter: setter, isExtern: isExtern, isMember: isMember, isStatic: isStatic) {
    this.interpreter = interpreter;
    if (initializer == null && declType == null) {
      _declType = HTTypeId.ANY;
    }
  }

  @override
  void initialize() {
    if (isInitialized) return;

    if (initializer != null) {
      if (!_isInitializing) {
        _isInitializing = true;
        final initVal = interpreter.visitASTNode(initializer!);
        assign(initVal);
        _isInitializing = false;
      } else {
        throw HTErrorCircleInit(id);
      }
    } else {
      assign(null); // null 也要 assign 一下，因为需要类型检查
    }
  }

  @override
  void assign(dynamic value) {
    if (_declType != null) {
      final encapsulation = interpreter.encapsulate(value);
      if (encapsulation.isNotA(_declType!)) {
        throw HTErrorTypeCheck(id, encapsulation.typeid.toString(), _declType.toString());
      }
    } else {
      if (!isDynamic && value != null) {
        _declType = interpreter.encapsulate(value).typeid;
      } else {
        _declType = HTTypeId.ANY;
      }
    }

    super.assign(value);
  }

  @override
  HTAstVariable clone() => HTAstVariable(id, interpreter,
      value: value,
      initializer: initializer,
      getter: getter,
      setter: setter,
      declType: declType,
      isExtern: isExtern,
      isImmutable: isImmutable);
}