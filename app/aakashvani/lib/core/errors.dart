sealed class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class AuthError extends AppError {
  const AuthError(super.message);
}

class UnknownError extends AppError {
  const UnknownError(super.message);
}
