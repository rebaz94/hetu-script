import 'dart:io';

import 'package:hetu_script/hetu_script.dart';

const cli_help = '''

  Hetu Script Command-line Tool
  Version: 0.0.1
  Usage:

  hetu [option] [file_name] [invoke_func]
  
  If only [file_name] is provided, evaluate the file in function mode.
  
  If [file_name] and [invoke_func] is both provided, will use program style interpretation.
        ''';

void main(List<String> args) async {
  try {
    var hetu = Hetu();

    dynamic result;
    if (args.isNotEmpty) {
      if ((args.first == '--help') || (args.first == '-h')) {
        print(cli_help);
      } else if (args.length == 1) {
        result = await hetu.import(args.first, style: ParseStyle.block);
      } else {
        result = await hetu.import(args.first, style: ParseStyle.module, invokeFunc: args[1]);
      }
      if (result != null) print(result);
    } else {
      stdout.writeln('\nHetu Script Read-Evaluate-Print-Loop Tool\n'
          'Version: 0.1.0\n\n'
          'Enter your code to evaluate.\n'
          'Enter \'\\\' for multiline, enter \'quit\' to quit.\n');
      var quit = false;

      while (!quit) {
        stdout.write('>>>');
        var input = stdin.readLineSync();

        if ((input == 'exit') || (input == 'quit') || (input == 'close') || (input == 'end')) {
          quit = true;
        } else {
          if (input!.endsWith('\\')) {
            input += '\n' + stdin.readLineSync()!;
          }

          try {
            result = await hetu.eval(input, style: ParseStyle.block);
            if (result != null) print(result);
          } catch (e) {
            print(e);
          }
        }
      }
    }
  } catch (e) {
    print(e);
  }
}