/// View state's type
enum ViewState {
  idle, 
  busy, // loding, or already running
  empty, //empty like empty mean
  error, //can't load, or just error
}

/// error type
enum ViewStateErrorType {
  defaultError,
  networkTimeOutError, //netwrok error
  unauthorizedError //typically (unlogin or unauthorized to get permission)
}

class ViewStateError {
  ViewStateErrorType _errorType;
  String message;
  String errorMessage;

  ViewStateError(this._errorType, {this.message, this.errorMessage}) {
    _errorType ??= ViewStateErrorType.defaultError;
    message ??= errorMessage;
  }

  ViewStateErrorType get errorType => _errorType;

  /// these variable are just to make code to write more easy
  get isDefaultError => _errorType == ViewStateErrorType.defaultError;
  get isNetworkTimeOut => _errorType == ViewStateErrorType.networkTimeOutError;
  get isUnauthorized => _errorType == ViewStateErrorType.unauthorizedError;

  @override
  String toString() {
    return 'ViewStateError{errorType: $_errorType, message: $message, errorMessage: $errorMessage}';
  }
}

//enum ConnectivityStatus { WiFi, Cellular, Offline }
