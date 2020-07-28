class SplashAds {
  final String status;
  final String adUrl;

  SplashAds({this.status, this.adUrl});

  SplashAds.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        adUrl = json['ads_link'];

  Map toJson() => {'status': status, 'ads_link': adUrl};
}
