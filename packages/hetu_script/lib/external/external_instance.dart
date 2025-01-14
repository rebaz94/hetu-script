import '../value/entity.dart';
import '../type/type.dart';
import '../type/nominal.dart';
import '../type/external.dart';
// import '../grammar/semantic.dart';
import '../error/error.dart';
import '../value/function/function.dart';
import '../value/class/class.dart';
import 'external_class.dart';
// import '../value/external_enum/external_enum.dart';
import '../interpreter/interpreter.dart';
import '../declaration/class/class_declaration.dart';

/// Class for external object.
class HTExternalInstance<T> with HTEntity, InterpreterRef {
  @override
  late final HTType valueType;

  /// the external object.
  final T externalObject;
  final String typeString;
  late final HTExternalClass? externalClass;

  HTClassDeclaration? klass;

  // HTExternalEnum? enumClass;

  /// Create a external class object.
  HTExternalInstance(
      this.externalObject, HTInterpreter interpreter, this.typeString) {
    this.interpreter = interpreter;
    final id = interpreter.lexicon.getBaseTypeId(typeString);
    if (interpreter.containsExternalClass(id)) {
      externalClass = interpreter.fetchExternalClass(id);
    } else {
      externalClass = null;
    }

    final def = interpreter.currentNamespace
        .memberGet(id, isRecursive: true, throws: false);
    if (def is HTClassDeclaration) {
      klass = def;
    }
    // else if (def is HTExternalEnum) {
    //   enumClass = def;
    // }
    if (klass != null) {
      valueType = HTNominalType(klass: klass!);
    } else {
      valueType = HTExternalType(typeString);
    }
  }

  @override
  dynamic memberGet(String varName, {String? from}) {
    if (externalClass != null) {
      final member = externalClass!.instanceMemberGet(externalObject, varName);
      if (member is Function && klass != null) {
        HTClass? currentKlass = klass! as HTClass;
        HTFunction? decl;
        while (decl == null && currentKlass != null) {
          decl = currentKlass.memberGet(varName, throws: false);
          currentKlass = currentKlass.superClass;
        }
        if (decl != null) {
          // Assign the value as if we are doing decl.resolve() here.
          decl.externalFunc = member;
          return decl;
        }
      } else {
        return member;
      }
    }
    throw HTError.undefined(varName);
  }

  @override
  void memberSet(String varName, dynamic varValue, {String? from}) {
    if (externalClass != null) {
      externalClass!.instanceMemberSet(externalObject, varName, varValue);
    } else {
      throw HTError.unknownExternalTypeName(typeString);
    }
  }
}
