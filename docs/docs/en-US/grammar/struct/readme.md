# Struct

Struct are a prototype base object similar to Javascript's object. It is a prototype based object system.

You can change a struct's prototype by internal member '$prototype'.

The most significant difference between struct and class, is that struct's member can be created and modified during runtime. And you won't get errors when accessing a non-exist struct member, you simply got a null value.

```javascript
obj.race = 'dragon'; // okay, this will define a new member on obj.
var lvl = obj.level; // okay, although lvl's value will be null
```

## Dynamically delete a struct member

It is possible to delete a struct field using 'delete' keyword.

```javascript
var a = {
  name: 'the world',
  meaning: 42,
};
delete a.meaning;
print(a); // { name: 'the world' }
```

## Literal struct

Literal struct are expressions in the form of '{key: value}'

```javascript
var obj = {
  name: 'jimmy'
  age: 17
}
```

The key must be either a identifier, or a string literal (not includes string interpolation).

## Named struct

Named struct's declaration are like class, you can have constructors, getter and setters.

You don't have to declare the fields before assign it like you must do in Class declarations. This is useful for constructor.

```javascript
struct Named {
  construct (name: str) {
    this.name = name
  }
}
```

The named struct declaration itself is also a struct. you can access and modify its member.

However this kind of modification won't affect the object that created before.

```dart
final n = Named('Jimmy')
Named.name = 'Jones'
print(n.name) // 'Jimmy'
```

You can define static fields on a named struct.

Unlike class static members, the object created by the struct constructor can also access these fields through '.' operator.

And if you changed the static fields in a named struct. All the object created from this named struct, nomatter it was created before or after the change, will be getting the new value.

```javascript
struct Named {
  static var race = 'Human'
  var name
  construct(name) {
    this.name = name
  }
}
final n = Named('Jimmy')
print(n.name) // Jimmy
print(Named.name) // null
Named.race = 'Dragon'
print(n.race) // Dragon
```

One important thing worth noted: within a named struct's method, **you cannot omit 'this' when accessing its own members** like you would do in a class method.

## Struct inherit

Named struct can declare its prototype same way as a class declare its super class.

The extended struct are not necessarily be another named struct, you can inherit a variable with a value of a struct literal.

```javascript
struct Animal {
  walk: () {
    print('Animal walking.')
  }
}
struct Bird extends Animal {
  fly: () {
    print('Bird flying.')
  }
  walk: () {
    print('Bird walking.')
  }
}
```

Redirecting constructors also works in struct. Except you cannot redirect to **super**, usage is same to class constructors.

```javascript
struct Tile {
  construct (left, top) {
    this.left = left
    this.top = top
  }

  construct fromPosition(position) : this(position.left, position.top)
}

final t1 = Tile(5, 5)
final t2 = Tile.fromPosition({left: 5, top: 5})

print(t1, t2)
```