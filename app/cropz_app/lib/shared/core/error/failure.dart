class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => 'Failure(message: $message)';
}
