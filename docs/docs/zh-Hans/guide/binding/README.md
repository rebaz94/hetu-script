# 和 Dart 代码的交互

在脚本中可以用三种方式和 Dart 代码进行交互：内置类，Json 和绑定。这三种方法各有优劣，可以根据实际需求选择。

## 和 Dart 传递值

你可以通过 **invoke()** 接口的参数来向脚本函数传递值。脚本会将这个函数的返回值直接返回到 Dart 这边。

```dart
final result = hetu.invoke('calculate', positionalArgs: [6, 7], namedArgs: {'isFloat': true};
// equivalent in script
// final result = calculate(6, 7, isFloat: true)
```

## 内置类

河图已经内置下面这些类的绑定，因此你可以直接在脚本中传递、修改这些对象：

- null
- bool
- int
- double (it is called float in the script)
- String
- List\<dynamic\>
- Set\<dynamic>
- Map\<dynamic, dynamic\>
- Function

你可以直接在脚本中使用 **[]** 语法来访问和修改 Dart 中的 **List, Map** 对象。也可以直接使用 **()** 来调用 Dart 中的函数。

## Json

脚本中的对象字面量，在 Dart 中体现为 **HTStruct** 对象。这个对象在 Dart 中可以像 Map 那样直接使用 **[]** 来修改其成员。在脚本中则具有 **toJson()** 和 **fromJson()** 接口。因此可以使用这个对象来在 Dart 和脚本之间传递数值。

例如我们在脚本中有如下定义：

```kotlin
fun main (data) {
  var book = prototype.fromJson(data)
  print(book)
}
```

在 Dart 代码中有如下定义：

```dart
final Map<String, dynamic> data = {
  'id': 324,
  'title': 'Catcher in the Rye',
}
hetu.invoke('main', positionalArgs: [data]);
```

我们将会在 Dart 中获得下面的输出结果：

```javascript
{
  id: 324,
  title: 'Catcher in the Rye',
}
```

## Binding

使用内置类和对象字面量来传递值比较简单快捷。但如果你想要使用 Dart 中的已有类定义，或者想要调用 Dart 函数，则需要通过绑定的方式。

### External function

你可以直接将任意 Dart 函数绑定到脚本中：

```dart
await hetu.init(externalFunctions: {
  'hello': () => {'greeting': 'hello'},
});
```

这样写比较简明易懂，但通过这种方式定义的外部函数绑定，将会使用 Dart 中的 **Function.apply** 功能调用，相比直接调用，这个功能的运行效率通常比较低下（大约慢 10 倍左右）。因此，建议以如下形式定义一个外部函数：

```dart
await hetu.init(externalFunctions: {
  'hello': (context, {positionalArgs, namedArgs, typeArgs}) => {'greeting': 'hello'},
});
```

包含类型的外部函数完整定义如下：

```dart
/// typedef of external function for binding.
typedef HTExternalFunction = dynamic Function(
    HTEntity entity,
    {List<dynamic> positionalArgs,
    Map<String, dynamic> namedArgs,
    List<HTType> typeArgs});
```

要使用你刚才定义的外部函数，需要在脚本中使用 **external** 关键字声明这个函数。

下面是一个绑定并使用外部函数的完整例子：

```typescript
import 'package:hetu_script/hetu_script.dart';

void main() async {
  var hetu = Hetu();
  await hetu.init(externalFunctions: {
    'hello': (HTEntity entity,
        {List<dynamic> positionalArgs = const [],
            Map<String, dynamic> namedArgs = const {},
            List<HTTypeId> typeArgs = const []}) => {'greeting': 'Hello from Dart!'},
  });
  final hetuValue = hetu.eval(r'''
      external fun hello
      var dartValue = hello()
      dartValue['reply'] = 'Hi, this is Hetu.'
      dartValue // the script will return the value of it's last expression
      ''');

  print('hetu value: $hetuValue');
}
```

上面的程序的输出结果是：

```
hetu value: {'greeting': 'Hello from Dart!', 'reply': 'Hi, this is Hetu.'}
```

### 绑定一个外部方法

你可以在脚本中的类定义中，定义外部方法（外部成员函数）。

```dart
class Someone {
  external fun calculate
}
```

对于脚本类中的外部成员函数，在 Dart 侧的定义和普通函数一样：

```dart
dynamic calculate(object, {positionalArgs, namedArgs, typeArgs}) {
  // do somthing about the object
};
```

但在绑定时，约定使用 className.funcName 的形式作为绑定名：

```dart
// the key of this external method have to be in the form of 'className.methodName'
hetu.bindExternalFunction('Someone.calculate', calculate);
```

然后在脚本中，外部方法就可以和普通脚本函数一样使用了：

```dart
var ss = Someone()
ss.calculate()
```

对于命名构造体（named struct），可以使用相同的方式来绑定外部成员函数：

```javascript
struct Person {
  external fun sing
}
```

### 外部类绑定的定义和声明

你可以在脚本中定义一个外部类，然后通过绑定的方式来访问它的静态成员或者实例成员。

外部类的绑定包含下面四部分的代码：

- 一个 Dart class 的声明。这部分是纯粹的 Dart。通常你已经写好了这部分代码，而且也无须作任何修改。

- 你需要写一个针对这个 Dart class 的 [extension](https://dart.dev/guides/language/extension-methods)，提供两个方法：**htFetch 和 htAssign**。 这是为了让解释器可以以某种类似反射的方法获取 Dart 对象的成员。

- 你需要通过继承 **HTExternalClass** 类定义一个外部类，包含 **memberGet, memberSet, instanceMemberGet, instanceMemberSet** 等函数。这个外部类需要使用解释器的 [**bindExternalClass()**](../../api_reference/dart/readme.md) 方法进行绑定，从而让解释器可以访问这个类的静态成员，以及其构造函数。

- 你还需要在脚本中使用 **external** 关键字声明这个类和其成员。这可以让脚本本身进行语法检查、函数参数赋初值等。

下面是一个定义并使用一个外部类的完整例子：

```dart
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_script/binding.dart';

class Person {
  static final races = <String>['Caucasian'];
  static String _level = '0';
  static String get level => _level;
  static set level(value) => _level = value;
  static String meaning(int n) => 'The meaning of life is $n';

  String get child => 'Tom';
  String name;
  String race;

  Person([this.name = 'Jimmy', this.race = 'Caucasian']);
  Person.withName(this.name, [this.race = 'Caucasian']);

  void greeting(String tag) {
    print('Hi! $tag');
  }
}

extension PersonBinding on Person {
  dynamic htFetch(String varName) {
    switch (varName) {
      case 'name':
        return name;
      case 'race':
        return race;
      case 'greeting':
        return (HTEntity entity,
                {List<dynamic> positionalArgs = const [],
                Map<String, dynamic> namedArgs = const {},
                List<HTType> typeArgs = const []}) =>
            greeting(positionalArgs.first);
      case 'child':
        return child;
      default:
        throw HTError.undefined(varName);
    }
  }

  void htAssign(String varName, dynamic varValue) {
    switch (varName) {
      case 'name':
        name = varValue;
        break;
      case 'race':
        race = varValue;
        break;
      default:
        throw HTError.undefined(varName);
    }
  }
}

class PersonClassBinding extends HTExternalClass {
  PersonClassBinding() : super('Person');

  @override
  dynamic memberGet(String varName) {
    switch (varName) {
      case 'Person':
        return (HTEntity entity,
                {List<dynamic> positionalArgs = const [],
                Map<String, dynamic> namedArgs = const {},
                List<HTType> typeArgs = const []}) =>
            Person(positionalArgs[0], positionalArgs[1]);
      case 'Person.withName':
        return (HTEntity entity,
                {List<dynamic> positionalArgs = const [],
                Map<String, dynamic> namedArgs = const {},
                List<HTType> typeArgs = const []}) =>
            Person.withName(positionalArgs[0],
                (positionalArgs.length > 1 ? positionalArgs[1] : 'Caucasion'));
      case 'Person.meaning':
        return (HTEntity entity,
                {List<dynamic> positionalArgs = const [],
                Map<String, dynamic> namedArgs = const {},
                List<HTType> typeArgs = const []}) =>
            Person.meaning(positionalArgs[0]);
      case 'Person.level':
        return Person.level;
      default:
        throw HTError.undefined(varName);
    }
  }

  @override
  void memberSet(String varName, dynamic varValue) {
    switch (varName) {
      case 'Person.race':
        throw HTError.immutable(varName);
      case 'Person.level':
        return Person.level = varValue;
      default:
        throw HTError.undefined(varName);
    }
  }

  @override
  dynamic instanceMemberGet(dynamic object, String varName) {
    var i = object as Person;
    return i.htFetch(varName);
  }

  @override
  void instanceMemberSet(dynamic object, String varName, dynamic varValue) {
    var i = object as Person;
    i.htAssign(varName, varValue);
  }
}

void main() {
  var hetu = Hetu();
  hetu.init(externalClasses: [PersonClassBinding()]);
  hetu.eval('''
      external class Person {
        var race: str
        construct([name: str = 'Jimmy', race: str = 'Caucasian']);
        get child
        static fun meaning(n: num)
        static get level
        static set level (value: str)
        construct withName(name: str, [race: str = 'Caucasian'])
        var name
        fun greeting(tag: str)
      }
      fun main {
        var p1: Person = Person()
        p1.greeting('jimmy')
        print(Person.meaning(42))
        print(typeof p1)
        print(p1.name)
        print(p1.child)
        print('My race is', p1.race)
        p1.race = 'Reptile'
        print('Oh no! My race turned into', p1.race)
        Person.level = '3'
        print(Person.level)

        var p2 = Person.withName('Jimmy')
        print(p2.name)
        p2.name = 'John'
      }
      ''', isModule: true, invokeFunc: 'main');
}
```

#### 外部 Getter

Getter 是用来访问对象属性的特殊函数。对于此种函数，你无须在 **external class binding** 或者 **extension on instance** 上定义完整的函数，而只需直接返回其对应的值即可。

#### 部分绑定

你无需让每个绑定定义都完全包含上述的四个部分。

- 如果你只定义了**外部类（external class binding）**，并没有定义**对象扩展方法（extension on instance）**，这意味着你可以在脚本中**以 className.memberName 的形式访问类静态成员**。

- 如果你在外部类中**不定义 memberGet 和 memberSet**，而**只定义 instanceMemberGet 和 instanceMemberSet**，这样你可以在脚本中直接使用这个 Dart 对象，只是**不能通过构造函数创建这个对象，或者访问静态成员**。

### Dart 函数解包装定义

某些情况下，你可能希望将一个脚本函数，当作普通的 Dart 函数，作为参数传递给另一个 Dart 函数（例如在 Flutter 的 Widget 构造函数中的 onPressed 之类的场合）。

你可以通过绑定一个解包装函数来实现这个目的。在脚本中，在函数名之前可以加上一个 **[]** 用来定义解包装函数：

```dart
fun [DartFunction] add(a: num, b: num) -> num {
  return a + b
}

fun getFunc {
  return add
}
```

你可以使用解释器上的 **bindExternalFunctionType()** 来绑定这个解包装函数。当然也可以直接在解释器初始化时，作为参数传入 **init()** 方法。

下面的例子展示了如何定义 **DartFunction** 这个解包装函数：

```dart
await hetu.init(externalFunctions: {
  externalFunctionTypedef: {
  'DartFunction': (HTFunction function) {
    return (int a, int b) {
      // must convert the return type here to let dart know its return value type.
      return function.call([a, b]) as int;
    };
  },
});
```

之后，当你在脚本中传递 **add** 函数时，就可以获得一个符合定义的 Dart 函数。

下面是一个例子。我们定义了另一个 Dart 函数。它需要一个函数作为传入的参数。此时我们就可以将刚才在脚本中定义的 **add** 函数直接传给他。

```dart
typedef DartFunction = int Function(int a, int b);

int hetuAdd(DartFunction func) {
  var func = hetu.invoke('getFunc');
  return func(6, 7);
}
```

对于解包装函数，我们通常使用如下的定义：

```dart
typedef HTExternalFunctionTypedef = Function Function(HTFunction hetuFunction);
```

### 自动绑定工具

_这个工具的贡献者目前很久没有更新了，并不适用于当前版本的河图和 Flutter。我们可能会在晚些时候更新它。_

感谢[rockingdice](https://github.com/rockingdice)的贡献，我们现在有一个自动化工具 [hetu-script-autobinding](https://github.com/hetu-script/hetu-script-autobinding) 用来生成一个 Dart 类的完整外部类绑定定义。