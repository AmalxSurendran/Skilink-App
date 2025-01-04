// ignore_for_file: file_names

class PartnerDetails {
  final String partnerName;
  final int gender;
  final String bio;
  final String countryName;
  final String stateName;
  final String district;
  final String pincode;
  final String serviceName;
  final CustomerAddress customerAddress;

  PartnerDetails({
    required this.partnerName,
    required this.gender,
    required this.bio,
    required this.countryName,
    required this.stateName,
    required this.district,
    required this.pincode,
    required this.serviceName,
    required this.customerAddress,
  });

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    return PartnerDetails(
      partnerName: json['partner_name'],
      gender: json['gender'],
      bio: json['bio'],
      countryName: json['country_name'],
      stateName: json['state_name'],
      district: json['district'],
      pincode: json['pincode'],
      serviceName: json['service_name'],
      customerAddress: CustomerAddress.fromJson(json['customer_address']),
    );
  }
}

class CustomerAddress {
  final int id;
  final String addressLine;
  final String countryName;
  final String stateName;
  final String district;
  final String pincode;

  CustomerAddress({
    required this.id,
    required this.addressLine,
    required this.countryName,
    required this.stateName,
    required this.district,
    required this.pincode,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'],
      addressLine: json['address_line'],
      countryName: json['country_name'],
      stateName: json['state_name'],
      district: json['district'],
      pincode: json['pincode'],
    );
  }
}
