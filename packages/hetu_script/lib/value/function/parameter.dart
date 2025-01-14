import '../variable/variable.dart';
import '../../declaration/function/abstract_parameter.dart';

// TODO: parameter's initializer must be a const expression.

/// An implementation of [HTVariable] for function parameter declaration.
class HTParameter extends HTVariable implements HTAbstractParameter {
  @override
  final bool isVariadic;

  @override
  final bool isOptional;

  @override
  final bool isNamed;

  @override
  final bool isInitialization;

  /// Create a standard [HTParameter].
  HTParameter({
    required super.id,
    required super.interpreter,
    super.fileName,
    super.moduleName,
    required super.closure,
    super.declType,
    super.definitionIp,
    super.definitionLine,
    super.definitionColumn,
    this.isVariadic = false,
    this.isOptional = false,
    this.isNamed = false,
    this.isInitialization = false,
  }) : super(isMutable: true);

  // @override
  // String toString() {
  //   final typeString = StringBuffer();
  //   if (declType != null) {
  //     typeString.write('$id: ');
  //     typeString.write(declType.toString());
  //   }
  //   return typeString.toString();
  // }

  @override
  void resolve({bool resolveType = true}) {
    super.resolve(resolveType: resolveType);
  }

  @override
  HTParameter clone() {
    return HTParameter(
      id: id!,
      interpreter: interpreter,
      fileName: fileName,
      moduleName: moduleName,
      closure: closure,
      declType: declType,
      definitionIp: definitionIp,
      definitionLine: definitionLine,
      definitionColumn: definitionColumn,
      isVariadic: isVariadic,
      isOptional: isOptional,
      isNamed: isNamed,
      isInitialization: isInitialization,
    );
  }
}
