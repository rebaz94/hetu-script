import 'package:test/test.dart';
import 'package:hetu_script/hetu_script.dart';

void main() {
  final hetu = Hetu();
  hetu.init();

  group('edge cases -', () {
    test('automatic semicolon insertion', () {
      final result = hetu.eval(r'''
          var j = 3
          var i =
            ('all' 
            + 'oha')
          ++j
          if (i is num) 
        ;
            return j
        ''');
      expect(
        result,
        4,
      );
    });
    test('late initialization', () {
      final result = hetu.eval(r'''
        fun getIndex {
          return 2
        }
        var tables = { 'weapon': [1,2,3] }
        var rows = tables['weapon'];
        var i = getIndex()
        rows[i]
      ''');
      expect(
        result,
        3,
      );
    });
    test('late initialization 2', () {
      final result = hetu.eval(r'''
        var list = [1,2,3,4]
        var item = list[3]
        list.removeLast()
        item
      ''');
      expect(
        result,
        4,
      );
    });
    test('var in lambda', () {
      final result = hetu.eval(r'''
        class Left {
          var age = 10
          fun m() {
            var b = Right(fun(n) {
              age = n
            })
            b.exec()
          }
        }
        class Right {
          var f
          construct(f) {
            this.f = f
          }
          fun exec () {
            f(5)
          }
        }
        var a = Left()
        a.m()
        a.age
      ''');
      expect(
        result,
        5,
      );
    });
    test('forward declaration 1', () {
      final result = hetu.eval(r'''
        var i = 42
        var j = i
        i = 4
        j
      ''');
      expect(
        result,
        42,
      );
    });
    test('forward declaration 2', () {
      final result = hetu.eval(r'''
        var i = 42
        i = 4
        var j = i
        j
      ''');
      expect(
        result,
        4,
      );
    });
    test('subget as left value', () {
      final result = hetu.eval(r'''
        var list = [1,2,3]
        list[0]--
        list[0]
      ''');
      expect(
        result,
        0,
      );
    });
  });

  group('null check operator -', () {
    test('nullable member get', () {
      final result = hetu.eval(r'''
        var a
        a?.value
      ''');
      expect(
        result,
        null,
      );
    });
    test('if null', () {
      final result = hetu.eval(r'''
        var a
        a ?? true
      ''');
      expect(
        result,
        true,
      );
    });
    test('null assign', () {
      final result = hetu.eval(r'''
        var a
        a ??= 'not null!'
      ''');
      expect(
        result,
        'not null!',
      );
    });
  });
}