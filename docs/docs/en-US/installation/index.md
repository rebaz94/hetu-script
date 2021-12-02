# Installation

## Dart project

Add 'hetu_script: 0.3.0+1' (or future higher versions) in your pubspec.yaml.

```yaml
dependencies:
  hetu_script: ^0.3.0+1
```

## Flutter project

To load a script file from assets, add the script file's path into your pubspec.yaml like other assets.
The default folder is 'assets/scripts/',

```yaml
assets:
  - assets/scripts/main.ht
```

Those script will be pre-loaded by the new init method on Hetu class: [initFlutter]. You don't need to use old [init]. Also note that this is an async function.

Then you can load a asset script file by [evalFile] method:

```dart
final hetu = Hetu();
await hetu.initFlutter();

final result = hetu.evalFile('main.ht', invokeFunc: 'main');
```

## File system and module import

To handle module import from physical disk within the script, there's another package called: 'hetu_script_dev_tools'.
To handle physical file system, you have to use the class HTFileSystemSourceContext provided by this package, to replace the default one:

```dart
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_script_dev_tools/hetu_script_dev_tools.dart';

void main() {
  final sourceContext = HTFileSystemSourceContext(root: '../../script/');
  final hetu = Hetu(sourceContext: sourceContext);
  hetu.init();
  final result = hetu.evalFile('import_test1.ht', invokeFunc: 'main');
  print(result);
```

content in 'import_test1.ht':

```kotlin
import 'hello.ht' as h

fun main {
  return h.hello()
}
```

content in 'hello.ht':

```
fun hello {
  return 'Hello, world!'
}
```

The 'hetu_script_dev_tools' also provided a REPL tool for quick testing.