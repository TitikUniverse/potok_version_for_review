class ApiError {
  factory ApiError.fromMap(Map<String, dynamic> json) => ApiError(
        error: json['error'] == null ? null : Error.fromMap(json['error']),
      );

  const ApiError({
    this.error,
  });

  final Error? error;
}

class Error {
  factory Error.fromMap(Map<String, dynamic> json) => Error(
        errorCode: json['errorCode'],
        errorTitle: json['errorTitle'],
        errorMessage: json['errorMessage'],
        validationErrors: json['validationErrors'] == null
            ? null
            : List<ValidationError>.from(json['validationErrors']
                .map((x) => ValidationError.fromMap(x))),
      );

  const Error({
    this.errorCode,
    this.errorTitle,
    this.errorMessage,
    this.validationErrors,
  });

  final int? errorCode;
  final String? errorTitle;
  final String? errorMessage;
  final List<ValidationError>? validationErrors;
}

class ValidationError {
  factory ValidationError.fromMap(Map<String, dynamic> json) => ValidationError(
        key: json['key'],
        errorMessage: json['errorMessage'],
      );

  const ValidationError({
    this.key,
    this.errorMessage,
  });

  final String? key;
  final String? errorMessage;
}
