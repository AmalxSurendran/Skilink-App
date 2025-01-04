import '../app/generalImports.dart';

class Api {
  static String getCountryCodes = "${baseUrl}v1/list_country_codes";
  static String getGuestHome = "${baseUrl}v1/home-customer";
  static String regOne = "${baseUrl}v1/customer-reg-one";
  static String regTwo = "${baseUrl}v1/customer-reg-two";
  static String regThree = "${baseUrl}v1/customer-reg-three";
  static String customerLogin = "${baseUrl}v1/customer-login";
  static String listAddress = "${baseUrl}v1/customer-address";
  static String countryListAddress = "${baseUrl}v1/customer-country-list";
  static String stateListAddress = "${baseUrl}v1/customer-state-list";
  static String searchPartners = "${baseUrl}v1/customer-list-partners";
  static String getPartnerDetails = "${baseUrl}v1/customer-partner-details";
  static String bookService = "${baseUrl}v1/customer-booking";
  static String getBookings = "${baseUrl}v1/customer-bookings";
  static String getBookingDetails = "${baseUrl}v1/customer-booking-detail";
  static String getProfileDetails = "${baseUrl}v1/customer-profile";
  static String addAddressCustomer = "${baseUrl}v1/customer-address";
  static String listSpecificServicePartners =
      "${baseUrl}v1/specific-partners-services";
  static String updateCustomerAddress =
      "${baseUrl}v1/customer-address-activate";
  static String resetPassword = "${baseUrl}v1/customer-reset-password";
  static String updateFullName = "${baseUrl}v1/customer-update-fullname";
  static String updateGender = "${baseUrl}v1/customer-update-gender";
  static String deleteAddress = "${baseUrl}v1/customer-address-delete";
  static String deleteAccount = "${baseUrl}v1/customer-delete";
  static String resetPasswordOtp = "${baseUrl}v1/customer-reset-password-otp";
  static String verifyPasswordOtp = "${baseUrl}v1/customer-verify-password-otp";
  static String updateToken = "${baseUrl}v1/customer-update-token";
}
