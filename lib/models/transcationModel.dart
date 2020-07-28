class Transcation {
  List data;
  Transcation({this.data});
  factory Transcation.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'];

    List<String> dataList = dataJson.cast<String>();

    return Transcation(data: dataList);
  }
}
