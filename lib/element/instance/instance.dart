import 'dart:collection';

import '../../error/error.dart';
import '../../grammar/lexicon.dart';
import '../../grammar/semantic.dart';
import '../../interpreter/abstract_interpreter.dart';
import '../../type/type.dart';
import '../../type/nominal_type.dart';
import '../function/function.dart';
import '../class/class.dart';
import '../class/cast.dart';
import '../variable/typed_variable_declaration.dart';
import '../namespace.dart';
import '../object.dart';
import 'instance_namespace.dart';

/// The Dart implementation of the instance in Hetu.
/// [HTInstance] carries all decl from its super classes.
/// [HTInstance] inherits all its super classes' [HTTypeID]s.
class HTInstance with HTObject, InterpreterRef {
  final String id;
  final int index;

  @override
  final HTNominalType valueType;

  String get classId => valueType.id;

  /// A [HTInstance] has all members inherited from all super classes,
  /// Key is the id of a super class.
  /// Value is the namespace of that class.
  /// This map keeps the sequence when insertion,
  /// this way when searches for members, the closest super class's
  /// member always found first.
  final LinkedHashMap<String, HTInstanceNamespace> _namespaces =
      LinkedHashMap();

  /// The [HTNamespace] for this instance.
  /// Variables will start from the lowest class,
  /// searching through all super classes.
  HTInstanceNamespace get namespace => _namespaces[classId]!;

  /// Create a default [HTInstance] instance.
  HTInstance(HTClass klass, AbstractInterpreter interpreter,
      {List<HTType> typeArgs = const [], Map<String, dynamic>? jsonObject})
      : id = SemanticNames.instance,
        index = klass.instanceIndex,
        valueType = HTNominalType(klass, typeArgs: typeArgs) {
    this.interpreter = interpreter;

    HTClass? curKlass = klass;
    // final extended = <HTValueType>[];
    HTInstanceNamespace? curNamespace = HTInstanceNamespace(
        id, interpreter.curModuleFullName, interpreter.curLibraryName, this,
        classId: curKlass.id, closure: klass.namespace);
    while (curKlass != null && curNamespace != null) {
      // 继承类成员，所有超类的成员都会分别保存
      for (final decl in curKlass.instanceMembers.values) {
        // TODO: check if override, and if so, check the type wether fits super's type.
        final clone = decl.clone();
        curNamespace.define(clone.id, clone);

        if (jsonObject != null && jsonObject.containsKey(clone.id)) {
          final value = jsonObject[clone.id];
          clone.value = value;
        }
      }

      _namespaces[curKlass.id] = curNamespace;

      // if (curKlass.extendedType != null) {
      //   extended.add(curKlass.extendedType!);
      // }
      curKlass = curKlass.superClass;
      if (curKlass != null) {
        curNamespace.next = HTInstanceNamespace(
            id, interpreter.curModuleFullName, interpreter.curLibraryName, this,
            classId: curKlass.id, closure: curKlass.namespace);
      } else {
        curNamespace.next = null;
      }

      curNamespace = curNamespace.next;
    }
  }

  @override
  String toString() {
    final func = memberGet('toString');
    if (func is HTFunction) {
      return func.call();
    } else if (func is Function) {
      return func();
    } else {
      return id;
    }
  }

  Map<String, dynamic> toJson() {
    final jsonObject = <String, dynamic>{};

    HTInstanceNamespace? curNamespace = namespace;
    while (curNamespace != null) {
      for (final decl in curNamespace.declarations.values) {
        if (decl is! HTTypedVariableDeclaration ||
            jsonObject.containsKey(decl.id)) {
          continue;
        }
        jsonObject[decl.id] = decl.value;
      }
      curNamespace = curNamespace.next;
    }

    return jsonObject;
  }

  @override
  bool contains(String field) {
    for (final space in _namespaces.values) {
      if (space.declarations.containsKey(field) ||
          space.declarations.containsKey('${SemanticNames.getter}$field') ||
          space.declarations.containsKey('${SemanticNames.setter}$field')) {
        return true;
      }
    }
    return false;
  }

  /// [HTInstance] overrided [HTObject]'s [memberGet],
  /// with a new named parameter [classId].
  /// If [classId] is provided, then the instance will
  /// only search that [classId]'s corresponed [HTInstanceNamespace].
  @override
  dynamic memberGet(String field,
      {String from = SemanticNames.global,
      String? classId,
      bool error = true}) {
    final getter = '${SemanticNames.getter}$field';

    if (classId == null) {
      for (final space in _namespaces.values) {
        if (space.declarations.containsKey(field)) {
          if (field.startsWith(HTLexicon.privatePrefix) &&
              !from.startsWith(space.fullName)) {
            throw HTError.privateMember(field);
          }

          final value = space.declarations[field]!.value;
          if (value is HTFunction &&
              value.category != FunctionCategory.literal) {
            value.context = namespace;
          }
          return value;
        } else if (space.declarations.containsKey(getter)) {
          if (field.startsWith(HTLexicon.privatePrefix) &&
              !from.startsWith(space.fullName)) {
            throw HTError.privateMember(field);
          }

          HTFunction func = space.declarations[getter]!.value;
          func.context = namespace;
          return func.call();
        }
      }
    } else {
      final space = _namespaces[classId]!;
      if (space.declarations.containsKey(field)) {
        if (field.startsWith(HTLexicon.privatePrefix) &&
            !from.startsWith(space.fullName)) {
          throw HTError.privateMember(field);
        }

        final value = space.declarations[field]!.value;
        if (value is HTFunction && value.category != FunctionCategory.literal) {
          value.context = _namespaces[classId];
        }
        return value;
      } else if (space.declarations.containsKey(getter)) {
        if (field.startsWith(HTLexicon.privatePrefix) &&
            !from.startsWith(space.fullName)) {
          throw HTError.privateMember(field);
        }

        HTFunction func = space.declarations[getter]!.value;
        func.context = _namespaces[classId];
        return func.call();
      }
    }

    // TODO: this part should be declared in the hetu script codes
    switch (field) {
      case 'valueType':
        return valueType;
      case 'toString':
        return ({positionalArgs, namedArgs, typeArgs}) =>
            '${SemanticNames.instanceOf} $valueType';
      case 'toJson':
        return ({positionalArgs, namedArgs, typeArgs}) => toJson();
      default:
        if (error) {
          throw HTError.undefined(field);
        }
    }
  }

  /// [HTInstance] overrided [HTObject]'s [memberSet],
  /// with a new named parameter [classId].
  /// If [classId] is provided, then the instance will
  /// only search that [classId]'s corresponed [HTInstanceNamespace].
  @override
  void memberSet(String field, dynamic varValue,
      {String from = SemanticNames.global,
      bool error = true,
      String? classId}) {
    final setter = '${SemanticNames.setter}$field';

    if (classId == null) {
      for (final space in _namespaces.values) {
        if (space.declarations.containsKey(field)) {
          if (field.startsWith(HTLexicon.privatePrefix) &&
              !from.startsWith(space.fullName)) {
            throw HTError.privateMember(field);
          }

          var decl = space.declarations[field]!;
          decl.value = varValue;
          return;
        } else if (space.declarations.containsKey(setter)) {
          if (field.startsWith(HTLexicon.privatePrefix) &&
              !from.startsWith(space.fullName)) {
            throw HTError.privateMember(field);
          }

          HTFunction method = space.declarations[setter]!.value;
          method.context = namespace;
          method.call(positionalArgs: [varValue]);
          return;
        }
      }
    } else {
      if (!_namespaces.containsKey(classId)) {
        throw HTError.notSuper(classId, interpreter.curSymbol!);
      }

      final space = _namespaces[classId]!;
      if (space.declarations.containsKey(field)) {
        if (field.startsWith(HTLexicon.privatePrefix) &&
            !from.startsWith(space.fullName)) {
          throw HTError.privateMember(field);
        }

        var decl = space.declarations[field]!;
        decl.value = varValue;
        return;
      } else if (space.declarations.containsKey(setter)) {
        if (field.startsWith(HTLexicon.privatePrefix) &&
            !from.startsWith(space.fullName)) {
          throw HTError.privateMember(field);
        }

        final method = space.declarations[setter]! as HTFunction;
        method.context = _namespaces[classId];
        method.call(positionalArgs: [varValue]);
        return;
      }
    }

    throw HTError.undefined(field);
  }

  /// Call a member function of this [HTInstance].
  dynamic invoke(String funcName,
      {List<dynamic> positionalArgs = const [],
      Map<String, dynamic> namedArgs = const {},
      List<HTType> typeArgs = const [],
      bool errorHandled = true}) {
    try {
      HTFunction func = memberGet(funcName, from: namespace.fullName);
      return func.call(
          positionalArgs: positionalArgs,
          namedArgs: namedArgs,
          typeArgs: typeArgs);
    } catch (error, stack) {
      if (errorHandled) {
        rethrow;
      } else {
        interpreter.handleError(error, stack);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is HTCast) {
      return this == other.object;
    }
    return hashCode == other.hashCode;
  }
}