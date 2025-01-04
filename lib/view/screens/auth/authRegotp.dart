// // ignore_for_file: file_names

// import 'package:customer/utils/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../utils/api.dart';
// import 'authRegThree.dart';

// class AuthRegOtp extends StatefulWidget {
//   const AuthRegOtp({super.key});

//   @override
//   _AuthRegOtpState createState() => _AuthRegOtpState();
// }

// class _AuthRegOtpState extends State<AuthRegOtp> {
//   final List<TextEditingController> otpControllers =
//       List.generate(6, (index) => TextEditingController());
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   late List<FocusNode> focusNodes;

//   @override
//   void initState() {
//     super.initState();

//     focusNodes = List.generate(6, (index) => FocusNode());
//   }

//   @override
//   void dispose() {
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: null,
//         backgroundColor: whiteColor,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Enter OTP',
//                       style: TextStyle(fontSize: 24),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: List.generate(
//                         6,
//                         (index) => SizedBox(
//                           width: 50,
//                           height: 50,
//                           child: TextFormField(
//                             controller: otpControllers[index],
//                             textAlign: TextAlign.center,
//                             keyboardType: TextInputType.number,
//                             obscureText: false,
//                             maxLength: 1,
//                             onChanged: (value) {
//                               if (value.isNotEmpty && index < 5) {
//                                 FocusScope.of(context)
//                                     .requestFocus(focusNodes[index + 1]);
//                               }
//                             },
//                             focusNode: focusNodes[index],
//                             decoration: const InputDecoration(
//                               counterText: '',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter OTP';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       style:
//                           ElevatedButton.styleFrom(backgroundColor: blackColor),
//                       onPressed: _submitOTP,
//                       child: const Text(
//                         'Submit OTP',
//                         style: TextStyle(color: whiteColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   void _submitOTP() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     String otpData =
//         otpControllers.map((controller) => controller.text).join('');

//     final prefs = await SharedPreferences.getInstance();
//     final int? tempId = prefs.getInt('tempId');

//     if (tempId == null) {
//       _showErrorDialog('Customer ID not found');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final formData = {
//       "id": tempId.toString(),
//       "otp_data": otpData,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(Api.regTwo), // Replace with your actual API URL
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(formData),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final customerId = responseData['id'];

//         final prefs = await SharedPreferences.getInstance();
//         prefs.setInt('tempId', customerId);

//         Navigator.of(context).pushReplacement(MaterialPageRoute(
//           builder: (context) =>
//               authRegThree(), // Replace with your actual screen widget
//         ));
//       } else {
//         print(response.body);
//         _showErrorDialog('Failed to verify OTP');
//       }
//     } catch (e) {
//       _showErrorDialog('Error verifying OTP: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// ignore_for_file: file_names

import 'package:customer/utils/colors.dart';
import 'package:customer/controller/authRegotp_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthRegOtp extends StatelessWidget {
  final AuthRegOtpController controller = Get.put(AuthRegOtpController());

  AuthRegOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: 50,
                            height: 50,
                            child: TextFormField(
                              controller: controller.otpControllers[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              obscureText: false,
                              maxLength: 1,
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).requestFocus(
                                      controller.focusNodes[index + 1]);
                                }
                              },
                              focusNode: controller.focusNodes[index],
                              decoration: const InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter OTP';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor),
                        onPressed: controller.submitOTP,
                        child: const Text(
                          'Submit OTP',
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
