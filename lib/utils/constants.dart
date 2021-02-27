String globalCaptchaValue = '';
const String spPhoneNumber = 'spPhoneNumber';
const String isUserAtChatBox = 'isUserAtChatBox';
const String isUserAtVoiceCallPage = 'isUserAtVoiceCallPage';
const String isUserOnForeground = 'isUserOnForeground';
const String kPartnerUserIdForChat = 'kPartnerUserIdForChat';
const int UNBLOCK = 0;
const int BLOCK = 1;
const int NORMAL_COMPRESS_QUALITY = 90;
const int LOW_COMPRESS_QUALITY = 80;

///Booking Status
const int UNKNOWN = -1;
const int PENDING = 0;
const int ACCEPTED = 1;
const int REJECT = 2;
const int DONE = 3;
const int EXPIRED = 4;
const int UNAVAILABLE = 5;
const int CANCEL = 6;

//datetime
const String renewDialog = "RenewDialog";

///Boosting Status
const int BOOST_UNKNOWN = -1;
const int BOOST_PENDING = 0;
const int BOOST_ACCEPTED = 1;
const int BOOST_REJECT = 2;
const int BOOST_DONE = 3;
const int BOOST_EXPIRED = 4;
const int BOOST_UNAVAILABLE = 5;
const int BOOST_CANCEL = 6;

///Message Type
const int MESSAGE = 0;
const int IMAGE = 1;
const int VIDEO = 2;
const int AUDIO = 3;
const int CALL = 4;
const int REQUEST = 7;
const int BOOSTING_REQUEST = 8;
//Reocrd Status
const String onStop = "onStop";
const String onStart = "onStart";

const int kNormal = 0;
const int kCoPlayer = 1;
const int kStreamer = 2;
const int kCele = 3;
const int kPro = 4;
const int kUnverifiedPartner = 5;
const int kWarriorPartner = 6;

const int kHomePostLimit = 20;
const int kChatListLimit = 20;
const int kFeedListLimit = 20;

const String kNewToBoosting = 'kNewToBoosting';
const String firsttimeboosting = 'firsttimeboosting';

///3 buttons for normal users
const String kFirstButton = 'kFirstButton';
const String kSecondButton = 'kSecondButton';
const String kThirdButton = 'kThirdButton';

const String kPartnerId = 'kPartnerId';

const String firstButtonMessage = 'Are you available for booking ?';
const String secondButtonMessage =
    'I want to play with you , where can I buy coin?';
const String thirdButtonMessage = 'What should I do to play with you?';

const String kDataBaseName = 'moongo.db';
const String kHomePostTableName = 'HomePostTable';
const String kNewFeedTableName = 'NewFeedTable';

const ONLINE = 0;
const BUSY = 1;
const AWAY = 2; // socket conn
const IN_GAME = 3; // server site
const BAN = -9;

enum UrlType { LOCAL_IMAGE, LOCAL_VIDEO, REMOTE_IMAGE, REMOTE_VIDEO, UNKNOWN }

const String kEdit = 'Edit';
const String kDelete = 'Delete';

enum PaymentStatus { PENDING, SUCCESS, REJECT, REFUND }

const String customProduct = 'custom_topup_coin';
