import 'package:equatable/equatable.dart';

class BaseResponse<T extends Object, E> extends Equatable {
  const BaseResponse._(this._responseStatus,
      {this.data,
      this.statusCode = -1,
      this.error,
      this.page = -1,
      this.totalPage = -1});

  const BaseResponse.refresh({T? data})
      : this._(_ResponseStatus.refresh, data: data);

  const BaseResponse.success(
      {T? data, int statusCode = 200, int page = -1, int totalPage = -1})
      : this._(_ResponseStatus.success,
            data: data,
            statusCode: statusCode,
            page: page,
            totalPage: totalPage);

  const BaseResponse.error({T? data, E? error, int? statusCode})
      : this._(_ResponseStatus.error,
            data: data, error: error, statusCode: statusCode ?? -1);

  const BaseResponse.errorWithCacheData({T? data, E? error, int? statusCode})
      : this._(_ResponseStatus.error,
            data: data, error: error, statusCode: statusCode);

  final _ResponseStatus? _responseStatus;
  final T? data;
  final E? error;
  final int? statusCode;
  final int page;
  final int totalPage;

  bool get isRefresh => _responseStatus == _ResponseStatus.refresh;

  bool get isSuccessful => _responseStatus == _ResponseStatus.success;

  bool get isError => _responseStatus == _ResponseStatus.error;

  BaseResponse<T, E> copyWith({
    T? data,
    E? error,
    int? statusCode,
    int? page,
    int? totalPage,
  }) {
    return BaseResponse._(
      _responseStatus,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      page: page ?? this.page,
      totalPage: totalPage ?? this.totalPage,
    );
  }

  @override
  List<Object?> get props => [
        statusCode,
        _responseStatus,
        data,
        error,
        page,
        totalPage,
      ];
}

enum _ResponseStatus { refresh, success, error }
