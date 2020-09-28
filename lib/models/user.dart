class User {
  String username;
  String profile;
  int id;
  int type;
  int status;
  int gameprofilecount;
  String tokenType;
  String token;
  String expiry;
  String name;
  String lastName;
  String email;
  String profileUrl;
  String coverUrl;
  //verify as partner api
  // String verify;
  int verified;
  int typestatus;
  String verifiedAt;
  String createdAt;
  String updatedAt;
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
        status = map['status'],
        gameprofilecount = map['game_profile_count'],
        tokenType = map['token_type'],
        token = map['token'],
        expiry = map['expiry'],
        name = map['name'],
        lastName = map['last_name'],
        email = map['email'],
        profileUrl = map['profile_image'],
        coverUrl = map['cover_image'],
        // verify = map['verify'],
        verified = map['verified'],
        typestatus = map['type_status'],
        verifiedAt = map['verified_at'],
        createdAt = map['created_at'],
        updatedAt = map['updated_at'],
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
    data['status'] = status;
    data['game_profile_count'] = gameprofilecount;
    data['token_type'] = tokenType;
    data['token'] = token;
    data['expiry'] = expiry;
    data['name'] = name;
    data['last_name'] = lastName;
    data['email'] = email;
    data['profile_image'] = profileUrl;
    data['cover_image'] = coverUrl;
    // data['verify'] = verify;
    data['verified'] = verified;
    data['type_status'] = typestatus;
    data['verified_at'] = verifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
