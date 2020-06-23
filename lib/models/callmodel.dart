//Call Made
class Callmade{
  String offer;
  int callerid;
  String media;
  
  Callmade ({this.offer, this.callerid, this.media});
  
  factory Callmade.fromJson(Map<String, dynamic> map){
   return Callmade( 
     offer: map['offer'],
     callerid: map['from'],
     media: map['media'],
   );
 }
}
//Answer Made
class Answermade {
  int callerid;
  String answer;

  Answermade(this.callerid, this.answer);
}