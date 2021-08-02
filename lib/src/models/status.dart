class Status {
  final int code;

  static final Status ok = Status(200);

  Status(this.code) : assert(code >= 100 && code <= 599);
}
