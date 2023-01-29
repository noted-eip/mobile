class ApiResponse {
  final int? statusCode;
  final dynamic data;
  final String? error;

  ApiResponse({this.statusCode, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      statusCode: json['statusCode'],
      data: json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data,
      'error': error,
    };
  }
}
