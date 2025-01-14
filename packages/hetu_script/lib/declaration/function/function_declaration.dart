import 'package:meta/meta.dart';

import '../../grammar/constant.dart';
import '../../type/type.dart';
import '../../type/function.dart';
import '../type/abstract_type_declaration.dart';
import '../declaration.dart';
import '../namespace/declaration_namespace.dart';
import 'abstract_parameter.dart';
import '../generic/generic_type_parameter.dart';
import '../../value/entity.dart';

class HTFunctionDeclaration extends HTDeclaration
    implements HasGenericTypeParameter {
  final String internalName;

  final FunctionCategory category;

  final String? externalTypeId;

  @override
  final List<HTGenericTypeParameter> genericTypeParameters;

  /// Wether to check params when called
  /// A function like:
  ///   ```
  ///     fun { return 42 }
  ///   ```
  /// will accept any params, while a function:
  ///   ```
  ///     fun () { return 42 }
  ///   ```
  /// will accept 0 params
  final bool hasParamDecls;

  /// Holds declarations of all parameters.
  final Map<String, HTAbstractParameter> paramDecls;

  HTType get returnType => declType.returnType;

  final HTFunctionType _declType;

  HTFunctionType? _resolvedDeclType;

  @override
  HTFunctionType get declType => _resolvedDeclType ?? _declType;

  final bool isAsync;

  final bool isField;

  final bool isAbstract;

  final bool isVariadic;

  final int minArity;

  final int maxArity;

  HTDeclarationNamespace? namespace;

  HTEntity? instance;

  bool _isResolved = false;
  @override
  bool get isResolved => _isResolved;

  HTFunctionDeclaration({
    required this.internalName,
    super.id,
    super.classId,
    super.closure,
    super.source,
    super.documentation,
    super.isExternal = false,
    super.isStatic = false,
    super.isConst = false,
    super.isTopLevel = false,
    this.category = FunctionCategory.normal,
    this.externalTypeId,
    this.genericTypeParameters = const [],
    this.hasParamDecls = true,
    this.paramDecls = const {},
    required HTFunctionType declType,
    this.isAsync = false,
    this.isField = false,
    this.isAbstract = false,
    this.isVariadic = false,
    this.minArity = 0,
    this.maxArity = 0,
    this.namespace,
  }) : _declType = declType;

  @override
  @mustCallSuper
  void resolve({bool resolveType = true}) {
    if (_isResolved) {
      return;
    }
    for (final param in paramDecls.values) {
      param.resolve();
    }
    if (resolveType && closure != null) {
      _resolvedDeclType = _declType.resolve(closure!) as HTFunctionType;
    }
    _isResolved = true;
  }

  @override
  HTFunctionDeclaration clone() => HTFunctionDeclaration(
      internalName: internalName,
      id: id,
      classId: classId,
      closure: closure,
      source: source,
      isExternal: isExternal,
      isStatic: isStatic,
      isConst: isConst,
      isTopLevel: isTopLevel,
      category: category,
      externalTypeId: externalTypeId,
      genericTypeParameters: genericTypeParameters,
      paramDecls: paramDecls,
      declType: declType,
      isField: isField,
      isAbstract: isAbstract,
      isVariadic: isVariadic,
      minArity: minArity,
      maxArity: maxArity,
      namespace: namespace);
}
