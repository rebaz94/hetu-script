import 'package:recase/recase.dart';

import '../grammar/lexicon.dart';
import '../analyzer/analyzer.dart' show AnalyzerConfig;
import 'error_severity.dart';

part 'error_processor.dart';

enum ErrorCode {
  unexpected,
  externalType,
  nestedClass,
  outsideReturn,
  setterArity,
  externalMember,
  emptyTypeArgs,
  extendsSelf,
  ctorReturn,
  missingFuncBody,
  internalFuncWithExternalTypeDef,
  externalCtorWithReferCtor,
  nonCotrWithReferCtor,
  moduleImport,
  invalidLeftValue,
  privateMember,
  constMustBeStatic,
  constMustInit,
  duplicateLibStmt,

  defined,
  outsideThis,
  notMember,
  notClass,
  abstracted,
  interfaceCtor,

  unsupported,
  extern,
  unknownOpCode,
  notInitialized,
  undefined,
  undefinedExternal,
  unknownTypeName,
  undefinedOperator,
  notCallable,
  undefinedMember,
  condition,
  notList,
  nullInit,
  nullObject,
  nullable,
  type,
  immutable,
  notType,
  argType,
  argInit,
  returnType,
  stringInterpolation,
  arity,
  binding,
  externalVar,
  bytesSig,
  circleInit,
  initialize,
  namedArg,
  iterable,
  unkownValueType,
  emptyString,
  typeCast,
  castee,
  clone,
  notSuper,
  missingExternalFunc,
  classOnInstance,
  version,
  sourceType,
  // nonExistModule
}

/// The type of an [HTError].
class ErrorType implements Comparable<ErrorType> {
  /// Task (todo) comments in user code.
  static const todo = ErrorType('TODO', 0, ErrorSeverity.info);

  /// Extra analysis run over the code to follow best practices, which are not in
  /// the Dart Language Specification.
  static const hint = ErrorType('HINT', 1, ErrorSeverity.info);

  /// Lint warnings describe style and best practice recommendations that can be
  /// used to formalize a project's style guidelines.
  static const lint = ErrorType('LINT', 2, ErrorSeverity.info);

  /// Syntactic errors are errors produced as a result of input that does not
  /// conform to the grammar.
  static const syntacticError =
      ErrorType('SYNTACTIC_ERROR', 3, ErrorSeverity.error);

  /// Reported by analyzer.
  static const staticTypeWarning =
      ErrorType('STATIC_TYPE_WARNING', 4, ErrorSeverity.warning);

  /// Reported by analyzer.
  static const staticWarning =
      ErrorType('STATIC_WARNING', 5, ErrorSeverity.warning);

  /// Compile-time errors are errors that preclude execution. A compile time
  /// error must be reported by a compiler before the erroneous code is
  /// executed.
  static const compileTimeError =
      ErrorType('COMPILE_TIME_ERROR', 6, ErrorSeverity.error);

  /// Run-time errors are errors that occurred during execution. A run time
  /// error is reported by the interpreter.
  static const runtimeError =
      ErrorType('RUNTIME_ERROR', 7, ErrorSeverity.error);

  /// External errors are errors reported by the dart side.
  static const externalError =
      ErrorType('EXTERNAL_ERROR', 8, ErrorSeverity.error);

  static const values = [
    todo,
    hint,
    lint,
    syntacticError,
    staticTypeWarning,
    staticWarning,
    compileTimeError,
    runtimeError,
    externalError
  ];

  /// The name of this error type.
  final String name;

  /// The weight value of the error type.
  final int weight;

  /// The severity of this type of error.
  final ErrorSeverity severity;

  /// Initialize a newly created error type to have the given [name] and
  /// [severity].
  const ErrorType(this.name, this.weight, this.severity);

  String get displayName => name.toLowerCase().replaceAll('_', ' ');

  @override
  int get hashCode => weight;

  @override
  int compareTo(ErrorType other) => weight - other.weight;

  @override
  String toString() => name;
}

abstract class AbstractError {
  ErrorCode get code;

  String get name;

  ErrorType get type;

  ErrorSeverity get severity => type.severity;

  String get message;

  String? get correction;

  String? get moduleFullName;

  int? get line;

  int? get column;

  int? get offset;

  int? get length;
}

class HTError implements AbstractError {
  @override
  final ErrorCode code;

  @override
  String get name => code.toString().split('.').last;

  @override
  final ErrorType type;

  @override
  ErrorSeverity get severity => type.severity;

  @override
  late final String message;

  @override
  final String? correction;

  @override
  final String? moduleFullName;

  @override
  final int? line;

  @override
  final int? column;

  @override
  final int? offset;

  @override
  final int? length;

  String? extra;

  @override
  String toString() {
    final output = StringBuffer();
    if (moduleFullName != null) {
      output.writeln('File: $moduleFullName');
      if (line != null && column != null) {
        output.writeln('Line: $line, Column: $column');
      }
    }
    final recase = ReCase(type.name);
    output.writeln('${recase.sentenceCase}: $name');
    output.writeln('Message: $message');
    if (extra != null) {
      output.writeln(extra);
    }
    return output.toString();
  }

  /// [HTError] can not be created by default constructor.
  HTError(this.code, this.type, String message,
      {List<String> interpolations = const [],
      this.correction,
      this.moduleFullName,
      this.line,
      this.column,
      this.offset,
      this.length}) {
    for (var i = 0; i < interpolations.length; ++i) {
      message = message.replaceAll('{$i}', interpolations[i]);
    }
    this.message = message;
  }

  /// Error: Expected a token while met another.
  HTError.unexpected(String expected, String met,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.unexpected, ErrorType.syntacticError,
            HTLexicon.errorUnexpected,
            interpolations: [expected, met],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: external type is not allowed.
  HTError.externalType(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.externalType, ErrorType.syntacticError,
            HTLexicon.errorExternalType,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Nested class within another nested class.
  HTError.nestedClass(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.nestedClass, ErrorType.syntacticError,
            HTLexicon.errorNestedClass,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Return appeared outside of a function.
  HTError.outsideReturn(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.outsideReturn, ErrorType.syntacticError,
            HTLexicon.errorOutsideReturn,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal setter declaration.
  HTError.setterArity(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.setterArity, ErrorType.syntacticError,
            HTLexicon.errorSetterArity,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal external member.
  HTError.externalMember(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.externalMember, ErrorType.syntacticError,
            HTLexicon.errorExternalMember,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Type arguments is emtpy brackets.
  HTError.emptyTypeArgs(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.emptyTypeArgs, ErrorType.syntacticError,
            HTLexicon.errorEmptyTypeArgs,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Symbol is not a class name.
  HTError.extendsSelf(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.extendsSelf, ErrorType.syntacticError,
            HTLexicon.errorExtendsSelf,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Not a super class of this instance.
  HTError.ctorReturn(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.ctorReturn, ErrorType.syntacticError,
            HTLexicon.errorCtorReturn,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to call a function without definition.
  HTError.missingFuncBody(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.missingFuncBody, ErrorType.syntacticError,
            HTLexicon.errorMissingFuncBody,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  HTError.internalFuncWithExternalTypeDef(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.missingExternalFunc, ErrorType.syntacticError,
            HTLexicon.errorInternalFuncWithExternalTypeDef,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  HTError.externalCtorWithReferCtor(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.externalCtorWithReferCtor, ErrorType.syntacticError,
            HTLexicon.errorExternalCtorWithReferCtor,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  HTError.nonCotrWithReferCtor(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.nonCotrWithReferCtor, ErrorType.syntacticError,
            HTLexicon.errorNonCotrWithReferCtor,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Module import error
  HTError.sourceProviderError(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.moduleImport, ErrorType.externalError,
            HTLexicon.errorSourceProviderError,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal value appeared on left of assignment.
  HTError.invalidLeftValue(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.invalidLeftValue, ErrorType.syntacticError,
            HTLexicon.errorInvalidLeftValue,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Access private member.
  HTError.privateMember(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.privateMember, ErrorType.syntacticError,
            HTLexicon.errorPrivateMember,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Const variable in a class must be static.
  HTError.constMustBeStatic(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.constMustBeStatic, ErrorType.syntacticError,
            HTLexicon.errorConstMustBeStatic,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Const variable must be initialized.
  HTError.constMustInit(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.constMustInit, ErrorType.syntacticError,
            HTLexicon.errorConstMustInit,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Duplicate library statement.
  HTError.duplicateLibStmt(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.duplicateLibStmt, ErrorType.syntacticError,
            HTLexicon.errorDuplicateLibStmt,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: A same name declaration is already existed.
  HTError.defined(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.defined, ErrorType.compileTimeError,
            HTLexicon.errorDefined,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: This appeared outside of a function.
  HTError.outsideThis(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.outsideThis, ErrorType.compileTimeError,
            HTLexicon.errorOutsideThis,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Symbol is not a class member.
  HTError.notMember(String id, String className,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notMember, ErrorType.compileTimeError,
            HTLexicon.errorNotMember,
            interpolations: [id, className],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Symbol is not a class name.
  HTError.notClass(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notClass, ErrorType.compileTimeError,
            HTLexicon.errorNotClass,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Cannot create instance from abstract class.
  HTError.abstracted(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.abstracted, ErrorType.compileTimeError,
            HTLexicon.errorAbstracted,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Cannot create contructor for interfaces.
  HTError.interfaceCtor(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.interfaceCtor, ErrorType.compileTimeError,
            HTLexicon.errorInterfaceCtor,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: unsupported runtime operation
  HTError.unsupported(String name,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.unsupported, ErrorType.runtimeError,
            HTLexicon.errorUnsupported,
            interpolations: [name],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: dart error
  HTError.extern(String message,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.extern, ErrorType.runtimeError, message,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Access private member.
  HTError.unknownOpCode(int opcode,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.unknownOpCode, ErrorType.runtimeError,
            HTLexicon.errorUnknownOpCode,
            interpolations: [opcode.toString()],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to use a variable before its initialization.
  HTError.notInitialized(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notInitialized, ErrorType.runtimeError,
            HTLexicon.errorNotInitialized,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to use a undefined variable.
  HTError.undefined(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.undefined, ErrorType.runtimeError,
            HTLexicon.errorUndefined,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to use a external variable without its binding.
  HTError.undefinedExternal(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.undefinedExternal, ErrorType.runtimeError,
            HTLexicon.errorUndefinedExternal,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to operate unkown type object.
  HTError.unknownTypeName(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.unknownTypeName, ErrorType.runtimeError,
            HTLexicon.errorUnknownTypeName,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Unknown operator.
  HTError.undefinedOperator(String id, String op,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.undefinedOperator, ErrorType.runtimeError,
            HTLexicon.errorUndefinedOperator,
            interpolations: [id, op],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: A same name declaration is already existed.
  HTError.definedRuntime(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.defined, ErrorType.runtimeError, HTLexicon.errorDefined,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Object is not callable.
  HTError.notCallable(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notCallable, ErrorType.runtimeError,
            HTLexicon.errorNotCallable,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Undefined member of a class/enum.
  HTError.undefinedMember(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.undefinedMember, ErrorType.runtimeError,
            HTLexicon.errorUndefinedMember,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: if/while condition expression must be boolean type.
  HTError.condition(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.condition, ErrorType.runtimeError,
            HTLexicon.errorCondition,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to use sub get operator on a non-list object.
  HTError.notList(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notList, ErrorType.runtimeError, HTLexicon.errorNotList,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Calling method on null object.
  HTError.errorNullInit(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.nullInit, ErrorType.runtimeError, HTLexicon.errorNullInit,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Calling method on null object.
  HTError.nullObject(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.nullObject, ErrorType.runtimeError,
            HTLexicon.errorNullObject,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Type is assign a unnullable varialbe with null.
  HTError.nullable(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.nullable, ErrorType.runtimeError, HTLexicon.errorNullable,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Type check failed.
  HTError.type(String id, String valueType, String declValue,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.type, ErrorType.runtimeError, HTLexicon.errorType,
            interpolations: [id, valueType, declValue],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to assign a immutable variable.
  HTError.immutable(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.immutable, ErrorType.runtimeError,
            HTLexicon.errorImmutable,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Symbol is not a type.
  HTError.notType(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.notType, ErrorType.runtimeError, HTLexicon.errorNotType,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Arguments type check failed.
  HTError.argType(String id, String assignType, String declValue,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.argType, ErrorType.runtimeError, HTLexicon.errorArgType,
            interpolations: [id, assignType, declValue],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Only optional or named arguments can have initializer.
  HTError.argInit(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.argInit, ErrorType.syntacticError, HTLexicon.errorArgInit,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Return value type check failed.
  HTError.returnType(
      String returnedType, String funcName, String declReturnType,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.returnType, ErrorType.runtimeError,
            HTLexicon.errorReturnType,
            interpolations: [returnedType, funcName, declReturnType],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: String interpolation has to be a single expression.
  HTError.stringInterpolation(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.stringInterpolation, ErrorType.syntacticError,
            HTLexicon.errorStringInterpolation,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Function arity check failed.
  HTError.arity(String id, int argsCount, int paramsCount,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.arity, ErrorType.runtimeError, HTLexicon.errorArity,
            interpolations: [argsCount.toString(), id, paramsCount.toString()],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Missing binding extension on dart object.
  HTError.binding(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.binding, ErrorType.runtimeError, HTLexicon.errorBinding,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Can not declare a external variable in global namespace.
  HTError.externalVar(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.externalVar, ErrorType.syntacticError,
            HTLexicon.errorExternalVar,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Bytecode signature check failed.
  HTError.bytesSig(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.bytesSig, ErrorType.runtimeError, HTLexicon.errorBytesSig,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Variable's initialization relies on itself.
  HTError.circleInit(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.circleInit, ErrorType.runtimeError,
            HTLexicon.errorCircleInit,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Missing variable initializer.
  HTError.initialize(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.initialize, ErrorType.runtimeError,
            HTLexicon.errorInitialize,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Named arguments does not exist.
  HTError.namedArg(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.namedArg, ErrorType.runtimeError, HTLexicon.errorNamedArg,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Object is not iterable.
  HTError.iterable(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.iterable, ErrorType.runtimeError, HTLexicon.errorIterable,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Unknown value type code
  HTError.unkownValueType(int valType,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.unkownValueType, ErrorType.runtimeError,
            HTLexicon.errorUnkownValueType,
            interpolations: [valType.toString()],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal empty string.
  HTError.emptyString(
      {ErrorType type = ErrorType.runtimeError,
      String? info,
      String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.emptyString, type, HTLexicon.errorEmptyString,
            interpolations: info != null ? [info] : const [],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal type cast.
  HTError.typeCast(String from, String to,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.typeCast, ErrorType.runtimeError, HTLexicon.errorTypeCast,
            interpolations: [from, to],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal castee.
  HTError.castee(String varName,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.castee, ErrorType.runtimeError, HTLexicon.errorCastee,
            interpolations: [varName],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Illegal clone.
  HTError.clone(String varName,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.clone, ErrorType.runtimeError, HTLexicon.errorClone,
            interpolations: [varName],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Not a super class of this instance.
  HTError.notSuper(String classId, String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(
            ErrorCode.notSuper, ErrorType.runtimeError, HTLexicon.errorNotSuper,
            interpolations: [classId, id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  HTError.missingExternalFunc(String id,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.missingExternalFunc, ErrorType.runtimeError,
            HTLexicon.errorMissingExternalFunc,
            interpolations: [id],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Try to define a class on a instance.
  HTError.classOnInstance(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.classOnInstance, ErrorType.runtimeError,
            HTLexicon.errorClassOnInstance,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Incompatible bytecode version.
  HTError.version(String codeVer, String itpVer,
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.version, ErrorType.runtimeError, HTLexicon.errorVersion,
            interpolations: [codeVer, itpVer],
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  /// Error: Unevalable source type.
  HTError.sourceType(
      {String? correction,
      String? moduleFullName,
      int? line,
      int? column,
      int? offset,
      int? length})
      : this(ErrorCode.sourceType, ErrorType.runtimeError,
            HTLexicon.errorSourceType,
            correction: correction,
            moduleFullName: moduleFullName,
            line: line,
            column: column,
            offset: offset,
            length: length);

  // HTError.nonExistModule(String key, ErrorType type,
  //     {String? correction,
  //     String? moduleFullName,
  //     int? line,
  //     int? column,
  //     int? offset,
  //     int? length})
  //     : this(ErrorCode.nonExistModule, type, HTLexicon.errorNonExistModule,
  //           interpolations: [key],
  //           correction: correction,
  //           moduleFullName: moduleFullName,
  //           line: line,
  //           column: column,
  //           offset: offset,
  //           length: length);
}
