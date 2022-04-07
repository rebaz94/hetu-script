import '../grammar/constant.dart';
import 'type.dart';

// An unknown object type passed into script from other language
class HTExternalType extends HTType {
  const HTExternalType(String id) : super(id: id);

  @override
  String toString() {
    return '${InternalIdentifier.externalType} $id';
  }
}
