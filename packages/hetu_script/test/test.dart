import 'package:hetu_script/hetu_script.dart';

void main() {
  var hetu = Hetu();
  hetu.init();
  hetu.eval(r'''
    fun structSet {
      print(() {} is ()->any)
    }
  ''', invokeFunc: 'structSet');
}