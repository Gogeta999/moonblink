class User {
  String username;
  String profile;
  int id;
  int type;
  String tokenType;
  String token;
  String expiry;
  String name;
  String last_name;
  String email;
  String profileUrl;
  String coverUrl;
  //verify as partner api
  // String verify;
  int verified;
  String verified_at;
  String created_at;
  String updated_at;
  String password;
  // for partner user
  int partnerUserid;
  String partnerPhone;
  String partnerMail;
  String partnerAddress;
  String partnerProfileImage;
  String partnerGender;
  String partnerNrc;
  String partnerDob;
  String partnerBios;
  String partnerCoverImage;
  String partnerUpdatedAt;
  String partnerCreatedAt;
  // User(this.mail, this.password, this.id, this.token);

  User.fromJsonMap(Map<String, dynamic> map)
      : username = map['username'],
        profile = map['profile'],
        id = map['id'],
        type = map['type'],
        tokenType = map['token_type'],
        token = map['token'],
        expiry = map['expiry'],
        name = map['name'],
        last_name = map['last_name'],
        email = map['email'],
        profileUrl = map['profile_image'],
        coverUrl = map['cover_image'],
        // verify = map['verify'],
        verified = map['verified'],
        verified_at = map['verified_at'],
        created_at = map['created_at'],
        updated_at = map['updated_at'],
        password = map['password'],
        partnerUserid = map['user_id'],
        partnerPhone = map['phone'],
        partnerMail = map['mail'],
        partnerAddress = map['address'],
        partnerProfileImage = map['profile_image'],
        partnerGender = map['gender'],
        partnerNrc = map['nrc'],
        partnerDob = map['dob'],
        partnerBios = map['bios'],
        partnerCoverImage = map['cover_image'],
        partnerUpdatedAt = map['updated_at'],
        partnerCreatedAt = map['created_at'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = username;
    data['profile'] = profile;
    data['id'] = id;
    data['type'] = type;
    data['token_type'] = tokenType;
    data['token'] = token;
    data['expiry'] = expiry;
    data['name'] = name;
    data['last_name'] = last_name;
    data['email'] = email;
    data['profile_image'] = profileUrl;
    data['cover_image'] = coverUrl;
    // data['verify'] = verify;
    data['verified'] = verified;
    data['verified_at'] = verified_at;
    data['created_at'] = created_at;
    data['updated_at'] = updated_at;
    data['password'] = password;

    data['user_id'] = partnerUserid;
    data['phone'] = partnerPhone;
    data['mail'] = partnerMail;
    data['address'] = partnerAddress;
    data['profile_image'] = partnerProfileImage;
    data['gender'] = partnerGender;
    data['nrc'] = partnerNrc;
    data['dob'] = partnerDob;
    data['bios'] = partnerBios;
    data['cover_image'] = partnerCoverImage;
    data['updated_at'] = partnerUpdatedAt;
    data['created_at'] = partnerCreatedAt;
    return data;
  }
}
