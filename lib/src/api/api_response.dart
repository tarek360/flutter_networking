class ApiResponse<T> {
  T? data;
  Exception? error;

  ApiResponse.success([this.data]);

  ApiResponse.failure(this.error);

  bool get hasData => data != null;

  bool get hasError => error != null;

  @override
  String toString() {
    return 'Error : $error \n Data : $data';
  }
}
