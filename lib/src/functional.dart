import 'package:dart_pact_consumer/src/json_serialize.dart';

typedef Mapper<T, R> = R Function(T input);

class Union2<T1, T2> {
  final T1? _t1;
  final T2? _t2;

  Union2._(this._t1, this._t2) : assert(_t1 != null || _t2 != null);

  Union2.t1(T1 t1) : this._(t1, null);

  Union2.t2(T2 t2) : this._(null, t2);

  R fold<R>(Mapper<T1, R> t1Mapper, Mapper<T2, R> t2Mapper) {
    return _fold(t1Mapper, _t1) ?? _fold(t2Mapper, _t2)!;
  }
}

class Union3<T1, T2, T3> {
  final T1? _t1;
  final T2? _t2;
  final T3? _t3;

  Union3._(this._t1, this._t2, this._t3)
      : assert(_t1 != null || _t2 != null || _t3 != null);

  Union3.t1(T1 t1) : this._(t1, null, null);

  Union3.t2(T2 t2) : this._(null, t2, null);

  Union3.t3(T3 t3) : this._(null, null, t3);

  R fold<R>(
      Mapper<T1, R> t1Mapper, Mapper<T2, R> t2Mapper, Mapper<T3, R> t3Mapper) {
    return _fold(t1Mapper, _t1) ??
        _fold(t2Mapper, _t2) ??
        _fold(t3Mapper, _t3)!;
  }
}

R? _fold<R, W>(Mapper<W, R> mapper, [Object? input]) {
  if (input is W) {
    return mapper(input);
  }
  return null;
}

final unit = Unit._();

/// Unit is a concept where a single instance exists.
///
/// In most cases it represents the absence of a value, like [Void].
///
/// Work with unions to provide a difference between actual null and something
/// that should be interpreted as null.
class Unit implements CustomJson {
  Unit._();

  @override
  dynamic toJson() => null;
}

/// Ensures a value either by provision or by lazy initialization
class Default<T> {
  T? _value;
  T Function()? _producer;

  Default._(this._value, this._producer)
      : assert(_producer != null || _value != null);

  factory Default.fromProducer(T Function() producer) {
    return Default._(null, producer);
  }

  factory Default.fromNullable(T? value, T Function() producer) {
    return Default._(value, producer);
  }

  T get value {
    _value ??= _producer?.call();
    assert(_value != null);
    _producer = null;
    return _value!;
  }
}

/// Replace with nullable
@deprecated
class Optional<T> extends Union2<T, Unit> {
  Optional.value(T value) : super.t1(value);

  Optional.empty() : super.t2(unit);

  factory Optional.nullable(T? value) {
    return value?.let((nonNull) => Optional.value(nonNull)) ?? Optional.empty();
  }
}

extension ScopeFunctions<T> on T? {
  /// Preforms an operation on a possible null input.
  ///
  /// The operation function is only executed on non null cases.
  R? let<R>(R Function(T value) func) {
    final tmp = this;
    if (tmp == null) {
      return null;
    }
    return func(tmp);
  }
}
