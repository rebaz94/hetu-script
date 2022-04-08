import 'type.dart';
import '../value/namespace/namespace.dart';

/// A type checks interfaces rather than type ids.
class HTStructuralType extends HTType {
  late final Map<String, HTType> fieldTypes;

  HTStructuralType(HTNamespace closure,
      {Map<String, HTType> fieldTypes = const {}}) {
    this.fieldTypes =
        fieldTypes.map((key, value) => MapEntry(key, value.resolve(closure)));
  }

  @override
  bool isA(HTType? other) {
    if (other == null) {
      return true;
    } else if (other is HTTypeAny) {
      return true;
    } else if (other is HTStructuralType) {
      if (other.fieldTypes.isEmpty) {
        return true;
      } else {
        if (other.fieldTypes.length != fieldTypes.length) {
          return false;
        } else {
          for (final key in other.fieldTypes.keys) {
            if (!fieldTypes.containsKey(key)) {
              return false;
            } else {
              if (fieldTypes[key]!.isNotA(other.fieldTypes[key])) {
                return false;
              }
            }
          }
          return true;
        }
      }
    } else {
      return false;
    }
  }
}
