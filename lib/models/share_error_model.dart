class ShareError {
  bool hasError;
  String? type;
  String? errorMessage;

  ShareError({required this.hasError, this.type, this.errorMessage});

  factory ShareError.fromMap(map) {
    return ShareError(
        hasError: map['hasErr'],
        type: map['type'],
        errorMessage: map['errMsg']);
  }
}
