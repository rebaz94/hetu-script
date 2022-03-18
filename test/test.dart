import 'package:hetu_script/lexer/lexer2.dart';

void main() {
  final source = r'''
/// single line comment
/*
  multi line comment
*/
fun main {
  print('hello, world!')
}
''';
  final lexer = HTLexer();
  final tokens = lexer.lex(source);
  for (final token in tokens) {
    print(token.lexeme);
  }
}
