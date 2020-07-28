import 'dart:collection';

class SplashAds {
  final String status;
  final String adUrl;

  SplashAds({this.status, this.adUrl});

  SplashAds.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        adUrl = json['ad_link'];

  Map toJson() => {'status': status, 'ads_link': adUrl};
  // factory SplashAds.fromJson(Map<String, dynamic> map) {
  //   return SplashAds(status: map['status'], adUrl: map['ads_link']);
  // }
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['status'] = status;
  //   data['ads_link'] = adUrl;
  //   return data;
  // }
  // @override
  // String toString() => 'stats: $status, ads_link: $adUrl';
}
