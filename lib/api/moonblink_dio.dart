import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/base_widget/forceDialog.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/platform_utils.dart';
//user token will change with data at login model
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:url_launcher/url_launcher.dart';

///Recreating Dio connection when api call - Fix
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class DioUtils {
  static final String baseUrl = Api.BASE; //base url
  static final String baseAppKey =
      'base64:c+JuepsZTyvv6MH7onjyx4/McJiumD38g3xNot/j6QA=';

  static final String devUrl = Api.DEV;
  static final String devAppKey =
      'base64:1CyzmcUAStrYcZ+IVkWrqwDJ52gK1naNYu68J9kQ04M=';
  static final DioUtils _instance = DioUtils._();
  factory DioUtils() => _instance;
  BaseOptions _baseOptions = BaseOptions(
    baseUrl: devUrl,
    connectTimeout: 10 * 1000,
    receiveTimeout: 8 * 1000,
    headers: {
      //Default necessary header
      //MoonBlink AppKey
      'app-key': devAppKey,
    },
    contentType: Headers.formUrlEncodedContentType,
    responseType: ResponseType.json,
  );

  Dio _dio;

  Map<String, dynamic> emptyData;

  /*
   * Init dio
   */
  DioUtils._() {
    var usertoken = StorageManager.sharedPreferences.getString(token);
    _dio = Dio(_baseOptions);
    if (usertoken != null) {
      initWithAuthorization();
    } else {
      initWithoutAuthorization();
    }
  }

  initWithAuthorization() {
    var usertoken = StorageManager.sharedPreferences.getString(token);
    if (usertoken != null) {
      _dio.interceptors.clear();
      _dio.interceptors.add(
        InterceptorsWrapper(onRequest: (RequestOptions requestions) async {
          String deviceId = await PlatformDeviceId.getDeviceId;
          var appVersion = await PlatformUtils.getAppVersion();
          requestions.headers['app-version'] = appVersion;
          requestions.headers['Authorization'] = 'Bearer' + usertoken;
          requestions.headers['device-id'] = deviceId;
          // debugPrint('Add---request---Token---headers-->\nUserTokenMap->'+requestions.headers.toString());
          return requestions;
        }, onResponse: (Response response) {
          //maybe add something here
          return response;
        }, onError: (DioError error) {
          //handle error
          return error;
        }),
      );
      print('Creating Dio connection to server with Authorization');
    }
  }

  initWithoutAuthorization() {
    // var usertoken = StorageManager.sharedPreferences.getString(token);
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions requestions) async {
        String deviceId = await PlatformDeviceId.getDeviceId;
        var appVersion = await PlatformUtils.getAppVersion();
        requestions.headers['app-version'] = appVersion;
        // requestions.headers['Authorization'] = 'Bearer' + usertokr
        requestions.headers['device-id'] = deviceId;
        debugPrint('Base Requestions--->' + requestions.headers.toString());
        return requestions;
      }, onResponse: (Response response) {
        //maybe add something here
        return response;
      }, onError: (DioError error) {
        //handle error
        return error;
      }),
    );
    print('Creating Dio connection to server without Authorization');
  }

  /*
   * get request
   */
  get(url, {queryParameters, options}) async {
    print('get---request---from--->$url');
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
      // 101 is token expired
      if (respData.errorCode == 101) {
        StorageManager.localStorage.deleteItem(mUser);
        StorageManager.sharedPreferences.remove(token);
        StorageManager.sharedPreferences.remove(mLoginName);
        StorageManager.sharedPreferences.remove(mUserId);
        StorageManager.sharedPreferences.remove(mUserType);
        throw forceLoginDialog();
      }
      // Platform and version Control
      // 102 is version late
      else if (respData.errorCode == 102 && Platform.isAndroid) {
        throw forceUpdateAndroidDialog();
      } else if (respData.errorCode == 102 && Platform.isIOS) {
        //TODO: navigate to ios store
      }
      // Request null data when no story
      else if (respData.errorCode == 123) {
        response.data = respData.data;
        // final emptyData = rootBundle.loadString("json/storyEmpty.json").then((value) => jsonDecode(value));
        debugPrint(
            'result--from--$url--->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
        return response;
      } else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }

  /*
   * Post request
   */
  post(
    url, {
    queryParameters,
    options,
  }) async {
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
        StorageManager.localStorage.deleteItem(mUser);
        StorageManager.sharedPreferences.remove(token);
        StorageManager.sharedPreferences.remove(mLoginName);
        StorageManager.sharedPreferences.remove(mUserId);
        StorageManager.sharedPreferences.remove(mUserType);
        throw forceLoginDialog();
      } // Platform and version Control
      // 102 is version late
      else if (respData.errorCode == 102 && Platform.isAndroid) {
        throw forceUpdateAndroidDialog();
      } else if (respData.errorCode == 102 && Platform.isIOS) {
        //TODO: navigate to ios store
      }
      // Request null data when no story
      else if (respData.errorCode == 123) {
        response.data = respData.data;
        // final emptyData = rootBundle.loadString("json/storyEmpty.json").then((value) => jsonDecode(value));
        debugPrint(
            'result--from--$url--->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
        return response;
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
        StorageManager.localStorage.deleteItem(mUser);
        StorageManager.sharedPreferences.remove(token);
        StorageManager.sharedPreferences.remove(mLoginName);
        StorageManager.sharedPreferences.remove(mUserId);
        StorageManager.sharedPreferences.remove(mUserType);
        throw forceLoginDialog();
        // throw ForceLoginDialog();
      } // Platform and version Control
      // 102 is version late
      else if (respData.errorCode == 102 && Platform.isAndroid) {
        throw forceUpdateAndroidDialog();
      } else if (respData.errorCode == 102 && Platform.isIOS) {
        //TODO: navigate to ios store
      }
      // Request null data when no story
      else if (respData.errorCode == 123) {
        response.data = respData.data;
        // final emptyData = rootBundle.loadString("json/storyEmpty.json").then((value) => jsonDecode(value));
        debugPrint(
            'result--from--$url--->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
        return response;
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
    print(response.statusCode);
    ResponseData respData = ResponseData.fromJson(response.data);
    if (respData.success) {
      response.data = respData.data;
      debugPrint(
          'api-post--->result----->${response.data}\napiResponseMessgae---->${respData.getMessage}');
      debugPrint('$respData');
      return respData;
    } else {
      if (respData.errorCode == 101) {
        StorageManager.localStorage.deleteItem(mUser);
        StorageManager.sharedPreferences.remove(token);
        StorageManager.sharedPreferences.remove(mLoginName);
        StorageManager.sharedPreferences.remove(mUserId);
        StorageManager.sharedPreferences.remove(mUserType);
        throw forceLoginDialog();
      } // Platform and version Control
      // 102 is version late
      else if (respData.errorCode == 102 && Platform.isAndroid) {
        throw forceUpdateAndroidDialog();
      } else if (respData.errorCode == 102 && Platform.isIOS) {
        //TODO: navigate to ios store
      }
      // Request null data when no story
      else if (respData.errorCode == 123) {
        response.data = respData.data;
        // final emptyData = rootBundle.loadString("json/storyEmpty.json").then((value) => jsonDecode(value));
        debugPrint(
            'result--from--$url--->${response.data}\nResponseMessgae--from-$url->${respData.getMessage}');
        return response;
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

  Future<void> forceLoginDialog() async {
    showDialog(
      barrierDismissible: false,
      context: locator<NavigationService>()
          .navigatorKey
          .currentState
          .overlay
          .context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(G.of(context).forceLoginTitle),
          content: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(G.of(context).forceLoginContent),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(G.of(context).confirm),
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> forceUpdateAndroidDialog() async {
    showDialog(
        context: locator<NavigationService>()
            .navigatorKey
            .currentState
            .overlay
            .context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(G.of(context).forceUpdateTitle),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(G.of(context).forceUpdateContent),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(G.of(context).cancel),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(G.of(context).confirm),
                onPressed: () {
                  _openStore();
                },
              ),
            ],
          );
        });
  }

  void _openStore() async {
    String appStoreUrl;
    if (Platform.isIOS) {
      appStoreUrl = 'fb://profile/103254564508101';
    } else {
      appStoreUrl =
          'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink';
    }
    const String pageUrl = 'https://www.facebook.com/Moonblink2000';
    try {
      bool nativeAppLaunch = await launch(appStoreUrl,
          forceSafariVC: false, universalLinksOnly: true);
      if (!nativeAppLaunch) {
        await launch(pageUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(pageUrl, forceSafariVC: false);
    }
  }
}

/// for child class's response data
abstract class BaseResponseData {
  int errorCode = 1;
  String errorMessage;
  int statusCode;
  dynamic data;
  String getMessage;

  bool get success;

  BaseResponseData(
      {this.errorCode,
      this.errorMessage,
      this.data,
      this.getMessage,
      this.statusCode});

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
    return 'Sorry, $message';
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
    statusCode = json['status_code'];
    print(statusCode);
    print(errorCode);

    ///remove later
    errorMessage = json['error_message'];
    getMessage = json['message'];
    data = json['data'];
  }
}
