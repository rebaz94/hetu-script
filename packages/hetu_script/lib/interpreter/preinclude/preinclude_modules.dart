/// This file has been automatically generated
/// from files in [hetu_lib] folder.
/// Please do not edit manually.
part of '../abstract_interpreter.dart';

/// The pre-included modules of Hetu scripting language.
final Map<String, String> preIncludeModules = const {
  'hetu:core': r'''// print values of any type into lines
external fun print(... args: any)

external fun stringify(obj: any)

// TODO: obj's type here should be '{}' (empty interface)
external fun jsonify(obj)

abstract class object {
  external fun toString() -> str
}

struct prototype {
  external static fun fromJson(data) // -> {}

  external get keys -> List

  external get values -> List

  /// Check if this struct has the key in its own fields
  external fun owns(key: str) -> bool

  /// Check if this struct has the key in its own fields or its prototypes' fields
  external fun contains(key: str) -> bool

  external fun clone() // -> {}

  fun toJson() -> Map => jsonify(this)

  fun toString() -> str => stringify(this)
}''',
  'hetu:value': r'''/// The apis here are named based on Dart SDK's
/// [num], [int], [double], [bool], [String], [List] and [Map]

// external class ExternalObject {

//   fun toString() -> str
// }

external class num {

	static fun parse(value: str) -> num

  fun compareTo(compareTo: num) -> int

  fun remainder(other: num) -> num

  /// Returns the integer closest to this number.
  fun round() -> int

  /// Returns the greatest integer no greater than this number.
  fun floor() -> int

  /// Returns the least integer which is not smaller than this number.
  fun ceil() -> int

  /// Returns the integer obtained by discarding any fractional
  /// part of this number.
  fun truncate() -> int

  /// Returns the integer double value closest to `this`.
  fun roundToDouble() -> float

  /// Returns the greatest integer double value no greater than `this`.
  fun floorToDouble() -> float

  /// Returns the least integer double value no smaller than `this`.
  fun ceilToDouble() -> float

  /// Returns the integer double value obtained by discarding any fractional
  /// digits from `this`.
  fun truncateToDouble() -> float

  get isNaN -> bool

  get isNegative -> bool

  get isInfinite -> bool

  get isFinite -> bool

  fun clamp(lowerLimit: num, upperLimit: num) -> num

  fun toStringAsFixed(fractionDigits: int) -> str

  fun toStringAsExponential([fractionDigits: int]) -> str

  fun toStringAsPrecision(precision: int) -> str
}

external class int extends num {
  /// Parse [source] as a, possibly signed, integer literal.
  static fun parse(source: str, {radix: int}) -> int
	
  /// Returns this integer to the power of [exponent] modulo [modulus].
  fun modPow(exponent: int, modulus: int) -> int

  /// Returns the modular multiplicative inverse of this integer
  fun modInverse(modulus: int) -> int

  /// Returns the greatest common divisor of this integer and [other].
  fun gcd(other: int) -> int

  /// Returns true if and only if this integer is even.
  get isEven -> bool

  /// Returns true if and only if this integer is odd.
  get isOdd -> bool

  /// Returns the minimum number of bits required to store this integer.
  get bitLength -> int
	
  /// Returns the least significant [width] bits of this integer as a
  /// non-negative number (i.e. unsigned representation).  The returned value has
  /// zeros in all bit positions higher than [width].
  fun toUnsigned(width: int) -> int
	
  /// Returns the least significant [width] bits of this integer, extending the
  /// highest retained bit to the sign.  This is the same as truncating the value
  /// to fit in [width] bits using an signed 2-s complement representation.  The
  /// returned value has the same bit value in all positions higher than [width].
  fun toSigned(width: int) -> int

  /// Returns the absolute value of this integer.
  fun abs() -> int

  /// Returns the sign of this integer.
  get sign -> int

  /// Converts [this] to a string representation in the given [radix].
  fun toRadixString(radix: int) -> str
}

/// An arbitrarily large integer.
external abstract class BigInt {
  static get zero
  static get one
  static get two

  /// Parses [source] as a, possibly signed, integer literal and returns its
  /// value.
  static fun parse(source: str, {radix: int}) -> BigInt

  /// Allocates a big integer from the provided [value] number.
  static fun from(value: num) -> BigInt

  /// Returns the absolute value of this integer.
  fun abs() -> BigInt

  /// Returns the remainder of the truncating division of `this` by [other].
  fun remainder(other: BigInt)

  /// Compares this to `other`.
  fun compareTo(other: BigInt) -> int

  /// Returns the minimum number of bits required to store this big integer.
  get bitLength -> int

  /// Returns the sign of this big integer.
  get sign -> int

  /// Whether this big integer is even.
  get isEven -> bool

  /// Whether this big integer is odd.
  get isOdd -> bool

  /// Whether this number is negative.
  get isNegative -> bool

  /// Returns `this` to the power of [exponent].
  fun pow(exponent: int) -> BigInt

  /// Returns this integer to the power of [exponent] modulo [modulus].
  fun modPow(exponent: BigInt, modulus: BigInt) -> BigInt

  /// Returns the modular multiplicative inverse of this big integer
  /// modulo [modulus].
  fun modInverse(modulus: BigInt) -> BigInt

  /// Returns the greatest common divisor of this big integer and [other].
  fun gcd(other: BigInt) -> BigInt

  /// Returns the least significant [width] bits of this big integer as a
  /// non-negative number (i.e. unsigned representation).  The returned value has
  /// zeros in all bit positions higher than [width].
  fun toUnsigned(width: int) -> BigInt

  /// Returns the least significant [width] bits of this integer, extending the
  /// highest retained bit to the sign.  This is the same as truncating the value
  /// to fit in [width] bits using an signed 2-s complement representation.  The
  /// returned value has the same bit value in all positions higher than [width].
  fun toSigned(width: int) -> BigInt

  /// Whether this big integer can be represented as an `int` without losing
  /// precision.
  get isValidInt -> bool

  /// Returns this [BigInt] as an [int].
  fun toInt() -> int

  /// Returns this [BigInt] as a [double].
  ///
  /// If the number is not representable as a [double], an
  /// approximation is returned. For numerically large integers, the
  /// approximation may be infinite.
  fun toDouble() -> float

  /// Returns a String-representation of this integer.
  fun toString() -> str

  /// Converts [this] to a string representation in the given [radix].
  fun toRadixString(radix: int) -> String
}

external class float extends num {
  
  static get nan -> float;
  static get infinity -> float;
  static get negativeInfinity -> float;
  static get minPositive -> float;
  static get maxFinite -> float;
	
	static fun parse(value: str) -> float
  
  /// Returns the absolute value of this number.
  fun abs() -> float

  /// Returns the sign of the double's numerical value.
  get sign -> float
}

external class bool {

	static fun parse(value: str) -> bool
}

external class str {

	static fun parse(value) -> str

  fun compareTo(index: str) -> int

  fun codeUnitAt(index: int) -> int

  get length -> int

	fun endsWith(other: str) -> bool

	fun startsWith(pattern: str, [index: num = 0]) -> bool

	fun indexOf(pattern: str, [start: num = 0]) -> num

	fun lastIndexOf(pattern, [start: num]) -> num

	get isEmpty -> bool

	get isNotEmpty -> bool

	fun substring(startIndex: num, [endIndex: num]) -> str

	fun trim() -> str

	fun trimLeft() -> str

	fun trimRight() -> str

	fun padLeft(width: num, [padding: str = ' ']) -> str

	fun padRight(width: num, [padding: str = ' ']) -> str

	fun contains(other: str, [startIndex: num = 0]) -> bool

	fun replaceFirst(from: str, to: str, [startIndex: num = 0]) -> str

	fun replaceAll(from: str, replace: str) -> str

	fun replaceRange(start: num, end: num, replacement: str) -> str

	fun split(pattern) -> List

	fun toLowerCase() -> str

	fun toUpperCase() -> str
}

external class List {

  fun toJson() => jsonify(this)

	get isEmpty -> bool

	get isNotEmpty -> bool

	fun contains(value) -> bool

	fun elementAt(index: int) -> any

	fun join(separator: str) -> str

	get first

	get last

	get length

	fun add(value)

  fun addAll(iterable)

  get reversed

	fun indexOf(value, [start: int = 0]) -> int

	fun lastIndexOf(value, [start: int]) -> int

	fun insert(index: int, value)

	fun insertAll(index: int, iterable)

	fun clear()

	fun remove(value)

	fun removeAt(index: int)

	fun removeLast()

  fun sublist(start: int, [end: int]) -> List

  fun asMap() -> Map
}

external class Map {

	get length -> num

	get isEmpty -> bool

	get isNotEmpty -> bool

  get keys -> List

  get values -> List

	fun containsKey(value) -> bool

	fun containsValue(value) -> bool

	fun addAll(other: Map)

	fun clear()

	fun remove(key)

  fun putIfAbsent(key, value) -> any
}''',
  'hetu:async': r'''external class Future {

  fun then(func: (value) -> any)
}
''',
  'hetu:system': r'''external class System {

  static get now -> num

  // static fun tik()

  // static fun tok()
}''',
  'hetu:math': r'''
external class Math {
  static final e: num = 2.718281828459045;
  
  static final pi: num = 3.1415926535897932;

  static fun min(a, b)

  static fun max(a, b)

  static fun random() -> num

  static fun randomInt(max: num) -> num

  static fun sqrt(x: num) -> num

  static fun pow(x: num, exponent: num) -> num

  static fun sin(x: num) -> num

  static fun cos(x: num) -> num

  static fun tan(x: num) -> num

  static fun exp(x: num) -> num

  static fun log(x: num) -> num

  static fun parseInt(source: str, {radix: int}) -> num

  static fun parseDouble(source: str) -> num

  static fun sum(list: List<num>) -> num

  static fun checkBit(index: num, check: num) -> bool

  static fun bitLS(x: num, distance: num) -> bool

  static fun bitRS(x: num, distance: num) -> bool

  static fun bitAnd(x: num, y: num) -> bool

  static fun bitOr(x: num, y: num) -> bool

  static fun bitNot(x: num) -> bool

  static fun bitXor(x: num, y: num) -> bool

}
''',
  'hetu:dev_tools': r'''external fun help(value) -> str''',
};
