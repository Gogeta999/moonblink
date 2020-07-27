import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
//user token will change with data at login model
import 'package:moonblink/view_model/login_model.dart';

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

// DioUtils http = DioUtils();
class DioUtils {
  static final String baseUrl = Api.BASE; //base url
  var usertoken = StorageManager.sharedPreferences.getString(token);
  static DioUtils _instance;
  Dio _dio;
  BaseOptions _baseOptions;

  Map<String, dynamic> emptyData;

  static DioUtils getInstance() {
    if (_instance == null) {
      _instance = new DioUtils();
    }
    return _instance;
  }

  /*
   * Init dio
   */
  DioUtils() {
    //request parametrs
    _baseOptions = new BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      headers: {
        //Default necessary header
        //appkey will remain old key unless we generate new key on server
        'app-key': 'base64:c+JuepsZTyvv6MH7onjyx4/McJiumD38g3xNot/j6QA=',
      },
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
    );

    //create dio instance
    _dio = new Dio(_baseOptions);

    //Adding necessary interceptor for our app
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions requestions) async {
        if (usertoken == null) {
          var appVersion = await PlatformUtils.getAppVersion();
          requestions.headers['app-version'] = appVersion;
          // debugPrint('Base Requestions--->' + requestions.headers.toString());
          return requestions;
        } else {
          var appVersion = await PlatformUtils.getAppVersion();
          requestions.headers['app-version'] = appVersion;
          requestions.headers['Authorization'] = 'Bearer' + usertoken;
          // debugPrint('Add---request---Token---headers-->\nUserTokenMap->'+requestions.headers.toString());
          return requestions;
        }
      }, onResponse: (Response response) {
        //maybe add something here
        return response;
      }, onError: (DioError error) {
        //handle error
        return error;
      }),
    );
  }

  /*
   * get request
   */
  get(url, {queryParameters, options}) async {
    // var appVersion = await PlatformUtils.getAppVersion();
    // var appPlatorm = Platform.operatingSystem;
    print('get---request---from--->$url');
    // print('requestParameter---is--->$queryParameters');
    // print('Test ah--platform is- {$appVersion}-verions-in-$appPlatorm----');
    Response response;
    response =
        await _dio.get(url, queryParameters: queryParameters, options: options);
    ResponseData respData = ResponseData.fromJson(response.data);
    // debugPrint('debug code error--- ${respData.data}');
    if (respData.success) {
      response.data = respData.data;
      debugPrint(
          'result--from---$url---->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
      return response;
    } else {
      // or if(usertoken = null)
      if (respData.errorCode == 101) {
        throw const UnAuthorizedException();
      }
      //TODO:
      // Platform and version Control
      else if (respData.errorCode == 102 && Platform.isAndroid) {
      } else if (respData.errorCode == 102 && Platform.isIOS) {
      }
      //Tell toe hlaing win to solve normal user problem
      else if (respData.errorCode == 123) {
        response.data = respData.data;
        // final emptyData = rootBundle.loadString("json/storyEmpty.json").then((value) => jsonDecode(value));
        debugPrint(
            'result--from--$url--->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
        // debugPrint('assetJson-->result---<$emptyData');
        // return emptyData;
        return response;
      }
      // 111 status is for newest user to see home page
      // else if (respData.errorCode == 111) {
      //   var newsetStory = {};
      // }
      else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }

  /*
   * Post request
   */
  post(url, {queryParameters, options}) async {
    print('post request path ------$url-------queryParameters$queryParameters');
    Response response;
    response = await _dio.post(url,
        queryParameters: queryParameters, options: options);
    ResponseData respData = ResponseData.fromJson(response.data);
    if (respData.success) {
      response.data = respData.data;
      debugPrint(
          'api-post--->result----->${response.data}\napiResponseMessgae---->${respData.getMessage}');
      return response;
    } else {
      if (respData.errorCode == 101) {
        throw const UnAuthorizedException();
      } else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }

  //delete request
  delete(url, {queryParameters, options}) async {
    print('post request path ------$url-------queryParameters$queryParameters');
    Response response;
    response = await _dio.delete(url,
        queryParameters: queryParameters, options: options);
    ResponseData respData = ResponseData.fromJson(response.data);
    if (respData.success) {
      response.data = respData.data;
      debugPrint(
          'api-post--->result----->${response.data}\napiResponseMessgae---->${respData.getMessage}');
      return response;
    } else {
      if (respData.errorCode == 101) {
        throw const UnAuthorizedException();
      } else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }

  /*
   * Post request
   */
  postwithData(url, {data, options}) async {
    print('post request path ------$url-------data $data');
    Response response;
    response = await _dio.post(url, data: data, options: options,
        onSendProgress: (int count, int total) {
      print('Uploading progress----->${count / total}----count/total process');
    });
    ResponseData respData = ResponseData.fromJson(response.data);
    if (respData.success) {
      response.data = respData.data;
      debugPrint(
          'api-post--->result----->${response.data}\napiResponseMessgae---->${respData.getMessage}');
      debugPrint('$respData');
      return respData;
    } else {
      if (respData.errorCode == 101) {
        throw const UnAuthorizedException();
      } else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }

  /*
   * Download
   */
  downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await _dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //Progress
        print("$count $total");
      });
      print('downloadFile success---------${response.data}');
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      formatError(e);
    }
    return response.data;
  }

  /*
   * Cancel Request
   *
  * The same cancel token can be used for multiple requests. When a cancel token is canceled, all requests using the cancel token will be canceled. 
  * So the parameters are optional
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  /*
   * For Download file
   */
  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      print("connecting timeout");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      print("sending timeout");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      print("receiving timeout");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("Incorrect status like 404, 503");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      print("Request cancelled");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("Unknown Error");
    }
  }
}

/// for child class's response data
abstract class BaseResponseData {
  int errorCode = 1;
  String errorMessage;
  dynamic data;
  String getMessage;

  bool get success;

  BaseResponseData(
      {this.errorCode, this.errorMessage, this.data, this.getMessage});

  @override
  String toString() {
    return 'BaseRespData{code: $errorCode, message: $errorMessage, data: $data}';
  }
}

/// The interface code did not return error
class NotSuccessException implements Exception {
  String message;

  NotSuccessException.fromRespData(BaseResponseData respData) {
    message = respData.errorMessage;
  }

  @override
  String toString() {
    // return 'NotExpectedException{respData: $message}';
    return 'Sorry,Please $message';
  }
}

/// unauthorize or un login error
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}

//Response from server
class ResponseData extends BaseResponseData {
  bool get success => 1 == errorCode;

  ResponseData.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    errorMessage = json['error_message'];
    getMessage = json['message'];
    data = json['data'];
  }
}
