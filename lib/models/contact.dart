class Contact{
 int partnerId;
 int userId;
 int followerId;
 int followingStatus;
 String createdAt; 
 ContactUser contactUser;

 Contact({this.partnerId, this.userId, this.followerId,
          this.followingStatus, this.createdAt, this.contactUser});

 factory Contact.fromJson(Map<String, dynamic> map){
   return Contact( 
     partnerId: map['id'],
     userId: map['user_id'],
     followerId: map['follower_id'],
     followingStatus: map['status'],
     createdAt: map['created_at'],
     contactUser: ContactUser.fromJson(map['user'])
   );
 }

}

class ContactUser{
  int contactUserId;
  String contactUserName;
  String contactUserProfile;

  ContactUser({this.contactUserId, this.contactUserName, this.contactUserProfile});

  factory ContactUser.fromJson(Map<String, dynamic> map){
    return ContactUser(
      contactUserId: map['id'],
      contactUserName: map['name'],
      contactUserProfile: map['profile_image'],
    );
  }
}