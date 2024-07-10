import 'dart:convert';
/// error : false
/// message : "Data retrived successfully"
/// data : [{"id":"153","ip_address":"49.36.16.205","username":"Rahul  Sharma","email":"a@gmail.com","mobile":"9755186862","image":null,"gender":"male","balance":"570","activation_selector":"a29a91b4266543b32f2d","activation_code":"$2y$10$EIVRSvrd7wDDv5CBTiC.Q.luFr.pz9l1ubPoAsyX/DZZvkq8sSJUm","forgotten_password_selector":null,"forgotten_password_code":null,"forgotten_password_time":null,"remember_selector":null,"remember_code":null,"created_on":"1648218075","last_login":"1648272756","active":"1","company":null,"address":"ddfds","bonus":"2","cash_received":"0.00","dob":"1998-03-14","country_code":null,"city":null,"area":null,"street":null,"license":"uploads/media/2022/sand.jpg","vehicle":"Mp 44 mc 3223","pincode":null,"serviceable_zipcodes":"9","apikey":null,"referral_code":null,"friends_code":null,"fcm_id":"f31YocDUQ-i69KeexwX71f:APA91bH5Xk-XZt4BpJ8IRo2ltBeHIRbJUj7Tjjsta-2FWPpWy0Aq0DJ1jBI87Vn4P5i3zTYizMeUNNvA2sPLo_WY99vYh7ZtLQPVNBdgO4ptYEBdPcDqu_InLYgVSfh2pX8Vji8KQMDY","latitude":null,"longitude":null,"open_close_status":"0","created_at":"2022-03-25 19:51:15","gst_file":"","food_lic":"","account_name":"dfddfd","pro_pic":"","account_number":"333333333333444444","bank_code":"uploads/media/2022/sand.jpg","bank_name":"uploads/media/2022/sand.jpg"}]
/// img_path : "https://alphawizztest.tk/ZuqZuq/"

GetBoUpdateModel getBoUpdateModelFromJson(String str) => GetBoUpdateModel.fromJson(json.decode(str));
String getBoUpdateModelToJson(GetBoUpdateModel data) => json.encode(data.toJson());
class GetBoUpdateModel {
  GetBoUpdateModel({
      bool? error, 
      String? message, 
      List<Data>? data, 
      String? imgPath,}){
    _error = error;
    _message = message;
    _data = data;
    _imgPath = imgPath;
}

  GetBoUpdateModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _imgPath = json['img_path'];
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
  String? _imgPath;
GetBoUpdateModel copyWith({  bool? error,
  String? message,
  List<Data>? data,
  String? imgPath,
}) => GetBoUpdateModel(  error: error ?? _error,
  message: message ?? _message,
  data: data ?? _data,
  imgPath: imgPath ?? _imgPath,
);
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;
  String? get imgPath => _imgPath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['img_path'] = _imgPath;
    return map;
  }

}

/// id : "153"
/// ip_address : "49.36.16.205"
/// username : "Rahul  Sharma"
/// email : "a@gmail.com"
/// mobile : "9755186862"
/// image : null
/// gender : "male"
/// balance : "570"
/// activation_selector : "a29a91b4266543b32f2d"
/// activation_code : "$2y$10$EIVRSvrd7wDDv5CBTiC.Q.luFr.pz9l1ubPoAsyX/DZZvkq8sSJUm"
/// forgotten_password_selector : null
/// forgotten_password_code : null
/// forgotten_password_time : null
/// remember_selector : null
/// remember_code : null
/// created_on : "1648218075"
/// last_login : "1648272756"
/// active : "1"
/// company : null
/// address : "ddfds"
/// bonus : "2"
/// cash_received : "0.00"
/// dob : "1998-03-14"
/// country_code : null
/// city : null
/// area : null
/// street : null
/// license : "uploads/media/2022/sand.jpg"
/// vehicle : "Mp 44 mc 3223"
/// pincode : null
/// serviceable_zipcodes : "9"
/// apikey : null
/// referral_code : null
/// friends_code : null
/// fcm_id : "f31YocDUQ-i69KeexwX71f:APA91bH5Xk-XZt4BpJ8IRo2ltBeHIRbJUj7Tjjsta-2FWPpWy0Aq0DJ1jBI87Vn4P5i3zTYizMeUNNvA2sPLo_WY99vYh7ZtLQPVNBdgO4ptYEBdPcDqu_InLYgVSfh2pX8Vji8KQMDY"
/// latitude : null
/// longitude : null
/// open_close_status : "0"
/// created_at : "2022-03-25 19:51:15"
/// gst_file : ""
/// food_lic : ""
/// account_name : "dfddfd"
/// pro_pic : ""
/// account_number : "333333333333444444"
/// bank_code : "uploads/media/2022/sand.jpg"
/// bank_name : "uploads/media/2022/sand.jpg"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      String? ipAddress, 
      String? username, 
      String? email, 
      String? mobile, 
      dynamic image, 
      String? gender, 
      String? balance, 
      String? activationSelector, 
      String? activationCode, 
      dynamic forgottenPasswordSelector, 
      dynamic forgottenPasswordCode, 
      dynamic forgottenPasswordTime, 
      dynamic rememberSelector, 
      dynamic rememberCode, 
      String? createdOn, 
      String? lastLogin, 
      String? active, 
      dynamic company, 
      String? address, 
      String? bonus, 
      String? cashReceived, 
      String? dob, 
      dynamic countryCode, 
      dynamic city, 
      dynamic area, 
      dynamic street, 
      String? license, 
      String? vehicle, 
      dynamic pincode, 
      String? serviceableZipcodes, 
      dynamic apikey, 
      dynamic referralCode, 
      dynamic friendsCode, 
      String? fcmId, 
      dynamic latitude, 
      dynamic longitude, 
      String? openCloseStatus, 
      String? createdAt, 
      String? gstFile, 
      String? foodLic, 
      String? accountName, 
      String? proPic, 
      String? accountNumber, 
      String? bankCode, 
      String? bankName,}){
    _id = id;
    _ipAddress = ipAddress;
    _username = username;
    _email = email;
    _mobile = mobile;
    _image = image;
    _gender = gender;
    _balance = balance;
    _activationSelector = activationSelector;
    _activationCode = activationCode;
    _forgottenPasswordSelector = forgottenPasswordSelector;
    _forgottenPasswordCode = forgottenPasswordCode;
    _forgottenPasswordTime = forgottenPasswordTime;
    _rememberSelector = rememberSelector;
    _rememberCode = rememberCode;
    _createdOn = createdOn;
    _lastLogin = lastLogin;
    _active = active;
    _company = company;
    _address = address;
    _bonus = bonus;
    _cashReceived = cashReceived;
    _dob = dob;
    _countryCode = countryCode;
    _city = city;
    _area = area;
    _street = street;
    _license = license;
    _vehicle = vehicle;
    _pincode = pincode;
    _serviceableZipcodes = serviceableZipcodes;
    _apikey = apikey;
    _referralCode = referralCode;
    _friendsCode = friendsCode;
    _fcmId = fcmId;
    _latitude = latitude;
    _longitude = longitude;
    _openCloseStatus = openCloseStatus;
    _createdAt = createdAt;
    _gstFile = gstFile;
    _foodLic = foodLic;
    _accountName = accountName;
    _proPic = proPic;
    _accountNumber = accountNumber;
    _bankCode = bankCode;
    _bankName = bankName;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _ipAddress = json['ip_address'];
    _username = json['username'];
    _email = json['email'];
    _mobile = json['mobile'];
    _image = json['image'];
    _gender = json['gender'];
    _balance = json['balance'];
    _activationSelector = json['activation_selector'];
    _activationCode = json['activation_code'];
    _forgottenPasswordSelector = json['forgotten_password_selector'];
    _forgottenPasswordCode = json['forgotten_password_code'];
    _forgottenPasswordTime = json['forgotten_password_time'];
    _rememberSelector = json['remember_selector'];
    _rememberCode = json['remember_code'];
    _createdOn = json['created_on'];
    _lastLogin = json['last_login'];
    _active = json['active'];
    _company = json['company'];
    _address = json['address'];
    _bonus = json['bonus'];
    _cashReceived = json['cash_received'];
    _dob = json['dob'];
    _countryCode = json['country_code'];
    _city = json['city'];
    _area = json['area'];
    _street = json['street'];
    _license = json['license'];
    _vehicle = json['vehicle'];
    _pincode = json['pincode'];
    _serviceableZipcodes = json['serviceable_zipcodes'];
    _apikey = json['apikey'];
    _referralCode = json['referral_code'];
    _friendsCode = json['friends_code'];
    _fcmId = json['fcm_id'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _openCloseStatus = json['open_close_status'];
    _createdAt = json['created_at'];
    _gstFile = json['gst_file'];
    _foodLic = json['food_lic'];
    _accountName = json['account_name'];
    _proPic = json['pro_pic'];
    _accountNumber = json['account_number'];
    _bankCode = json['bank_code'];
    _bankName = json['bank_name'];
  }
  String? _id;
  String? _ipAddress;
  String? _username;
  String? _email;
  String? _mobile;
  dynamic _image;
  String? _gender;
  String? _balance;
  String? _activationSelector;
  String? _activationCode;
  dynamic _forgottenPasswordSelector;
  dynamic _forgottenPasswordCode;
  dynamic _forgottenPasswordTime;
  dynamic _rememberSelector;
  dynamic _rememberCode;
  String? _createdOn;
  String? _lastLogin;
  String? _active;
  dynamic _company;
  String? _address;
  String? _bonus;
  String? _cashReceived;
  String? _dob;
  dynamic _countryCode;
  dynamic _city;
  dynamic _area;
  dynamic _street;
  String? _license;
  String? _vehicle;
  dynamic _pincode;
  String? _serviceableZipcodes;
  dynamic _apikey;
  dynamic _referralCode;
  dynamic _friendsCode;
  String? _fcmId;
  dynamic _latitude;
  dynamic _longitude;
  String? _openCloseStatus;
  String? _createdAt;
  String? _gstFile;
  String? _foodLic;
  String? _accountName;
  String? _proPic;
  String? _accountNumber;
  String? _bankCode;
  String? _bankName;
Data copyWith({  String? id,
  String? ipAddress,
  String? username,
  String? email,
  String? mobile,
  dynamic image,
  String? gender,
  String? balance,
  String? activationSelector,
  String? activationCode,
  dynamic forgottenPasswordSelector,
  dynamic forgottenPasswordCode,
  dynamic forgottenPasswordTime,
  dynamic rememberSelector,
  dynamic rememberCode,
  String? createdOn,
  String? lastLogin,
  String? active,
  dynamic company,
  String? address,
  String? bonus,
  String? cashReceived,
  String? dob,
  dynamic countryCode,
  dynamic city,
  dynamic area,
  dynamic street,
  String? license,
  String? vehicle,
  dynamic pincode,
  String? serviceableZipcodes,
  dynamic apikey,
  dynamic referralCode,
  dynamic friendsCode,
  String? fcmId,
  dynamic latitude,
  dynamic longitude,
  String? openCloseStatus,
  String? createdAt,
  String? gstFile,
  String? foodLic,
  String? accountName,
  String? proPic,
  String? accountNumber,
  String? bankCode,
  String? bankName,
}) => Data(  id: id ?? _id,
  ipAddress: ipAddress ?? _ipAddress,
  username: username ?? _username,
  email: email ?? _email,
  mobile: mobile ?? _mobile,
  image: image ?? _image,
  gender: gender ?? _gender,
  balance: balance ?? _balance,
  activationSelector: activationSelector ?? _activationSelector,
  activationCode: activationCode ?? _activationCode,
  forgottenPasswordSelector: forgottenPasswordSelector ?? _forgottenPasswordSelector,
  forgottenPasswordCode: forgottenPasswordCode ?? _forgottenPasswordCode,
  forgottenPasswordTime: forgottenPasswordTime ?? _forgottenPasswordTime,
  rememberSelector: rememberSelector ?? _rememberSelector,
  rememberCode: rememberCode ?? _rememberCode,
  createdOn: createdOn ?? _createdOn,
  lastLogin: lastLogin ?? _lastLogin,
  active: active ?? _active,
  company: company ?? _company,
  address: address ?? _address,
  bonus: bonus ?? _bonus,
  cashReceived: cashReceived ?? _cashReceived,
  dob: dob ?? _dob,
  countryCode: countryCode ?? _countryCode,
  city: city ?? _city,
  area: area ?? _area,
  street: street ?? _street,
  license: license ?? _license,
  vehicle: vehicle ?? _vehicle,
  pincode: pincode ?? _pincode,
  serviceableZipcodes: serviceableZipcodes ?? _serviceableZipcodes,
  apikey: apikey ?? _apikey,
  referralCode: referralCode ?? _referralCode,
  friendsCode: friendsCode ?? _friendsCode,
  fcmId: fcmId ?? _fcmId,
  latitude: latitude ?? _latitude,
  longitude: longitude ?? _longitude,
  openCloseStatus: openCloseStatus ?? _openCloseStatus,
  createdAt: createdAt ?? _createdAt,
  gstFile: gstFile ?? _gstFile,
  foodLic: foodLic ?? _foodLic,
  accountName: accountName ?? _accountName,
  proPic: proPic ?? _proPic,
  accountNumber: accountNumber ?? _accountNumber,
  bankCode: bankCode ?? _bankCode,
  bankName: bankName ?? _bankName,
);
  String? get id => _id;
  String? get ipAddress => _ipAddress;
  String? get username => _username;
  String? get email => _email;
  String? get mobile => _mobile;
  dynamic get image => _image;
  String? get gender => _gender;
  String? get balance => _balance;
  String? get activationSelector => _activationSelector;
  String? get activationCode => _activationCode;
  dynamic get forgottenPasswordSelector => _forgottenPasswordSelector;
  dynamic get forgottenPasswordCode => _forgottenPasswordCode;
  dynamic get forgottenPasswordTime => _forgottenPasswordTime;
  dynamic get rememberSelector => _rememberSelector;
  dynamic get rememberCode => _rememberCode;
  String? get createdOn => _createdOn;
  String? get lastLogin => _lastLogin;
  String? get active => _active;
  dynamic get company => _company;
  String? get address => _address;
  String? get bonus => _bonus;
  String? get cashReceived => _cashReceived;
  String? get dob => _dob;
  dynamic get countryCode => _countryCode;
  dynamic get city => _city;
  dynamic get area => _area;
  dynamic get street => _street;
  String? get license => _license;
  String? get vehicle => _vehicle;
  dynamic get pincode => _pincode;
  String? get serviceableZipcodes => _serviceableZipcodes;
  dynamic get apikey => _apikey;
  dynamic get referralCode => _referralCode;
  dynamic get friendsCode => _friendsCode;
  String? get fcmId => _fcmId;
  dynamic get latitude => _latitude;
  dynamic get longitude => _longitude;
  String? get openCloseStatus => _openCloseStatus;
  String? get createdAt => _createdAt;
  String? get gstFile => _gstFile;
  String? get foodLic => _foodLic;
  String? get accountName => _accountName;
  String? get proPic => _proPic;
  String? get accountNumber => _accountNumber;
  String? get bankCode => _bankCode;
  String? get bankName => _bankName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['ip_address'] = _ipAddress;
    map['username'] = _username;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['image'] = _image;
    map['gender'] = _gender;
    map['balance'] = _balance;
    map['activation_selector'] = _activationSelector;
    map['activation_code'] = _activationCode;
    map['forgotten_password_selector'] = _forgottenPasswordSelector;
    map['forgotten_password_code'] = _forgottenPasswordCode;
    map['forgotten_password_time'] = _forgottenPasswordTime;
    map['remember_selector'] = _rememberSelector;
    map['remember_code'] = _rememberCode;
    map['created_on'] = _createdOn;
    map['last_login'] = _lastLogin;
    map['active'] = _active;
    map['company'] = _company;
    map['address'] = _address;
    map['bonus'] = _bonus;
    map['cash_received'] = _cashReceived;
    map['dob'] = _dob;
    map['country_code'] = _countryCode;
    map['city'] = _city;
    map['area'] = _area;
    map['street'] = _street;
    map['license'] = _license;
    map['vehicle'] = _vehicle;
    map['pincode'] = _pincode;
    map['serviceable_zipcodes'] = _serviceableZipcodes;
    map['apikey'] = _apikey;
    map['referral_code'] = _referralCode;
    map['friends_code'] = _friendsCode;
    map['fcm_id'] = _fcmId;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['open_close_status'] = _openCloseStatus;
    map['created_at'] = _createdAt;
    map['gst_file'] = _gstFile;
    map['food_lic'] = _foodLic;
    map['account_name'] = _accountName;
    map['pro_pic'] = _proPic;
    map['account_number'] = _accountNumber;
    map['bank_code'] = _bankCode;
    map['bank_name'] = _bankName;
    return map;
  }

}