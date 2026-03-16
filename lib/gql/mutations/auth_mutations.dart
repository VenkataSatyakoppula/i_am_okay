import '../fragments.dart';

const String requestOtpMutation = """
  mutation RequestOTP(\$mobile: String!, \$phoneExt: String, \$isRegister: Boolean) {
    requestOtp(mobileNumber: \$mobile, phoneExt: \$phoneExt, isRegister: \$isRegister)
  }
""";

const String verifyOtpMutation =
    """
  mutation VerifyOTP(\$mobile: String!, \$otp: String!, \$phoneExt: String, \$userDetails: UserInsertInput, \$isEmergencyContact: Boolean) {
    verifyOtp(mobileNumber: \$mobile, code: \$otp, phoneExt: \$phoneExt, userDetails: \$userDetails, isEmergencyContact: \$isEmergencyContact) {
      token
      user {
        ...UserFields
      }
    }
  }
  $userFragment
""";
