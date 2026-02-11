sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get value => (this as Ok<T>).data;
  String get error => (this as Err<T>).message;

  R when<R>({
    required R Function(T data) ok,
    required R Function(String message) err,
  }) {
    return switch (this) {
      Ok(:final data) => ok(data),
      Err(:final message) => err(message),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}
