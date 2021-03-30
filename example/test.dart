import 'package:hetu_script/hetu_script.dart';

void main() async {
  final hetu = Hetu();
  await hetu.init();
  await hetu.eval(r'''
    fun main {
      var m = {}
      var name = 'table'
      m[name] = [1,2,3]

      print(m)
      print(m[name])
    }

  ''', invokeFunc: 'main');
}
