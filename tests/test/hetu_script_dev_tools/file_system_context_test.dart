import 'package:test/test.dart';
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_script_dev_tools/hetu_script_dev_tools.dart';

void main() {
  final sourceContext = HTFileSystemSourceContext(root: '../script/');
  final hetu = Hetu(sourceContext: sourceContext);
  hetu.init();

  group('module -', () {
    test('import 1', () {
      final result = hetu.evalFile('import_test.ht', invokeFunc: 'importTest');
      expect(
        result,
        87.5,
      );
    });
    test('import 2', () {
      final result = hetu.evalFile('import_test2.ht', invokeFunc: 'main');
      expect(
        result,
        'Hello, world!',
      );
    });
  });
}