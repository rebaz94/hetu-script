import 'package:hetu_script/hetu_script.dart';

void main() async {
  final hetu = HTAnalyzer();
  await hetu.init();
  await hetu.eval(
    r'''
    print(1 is! num)
  ''',
    config: InterpreterConfig(sourceType: SourceType.script),
    // invokeFunc: 'forwardDecl',
  );
}