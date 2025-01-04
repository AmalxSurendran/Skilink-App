// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, file_names

import 'dart:async';
import 'package:customer/utils/api.dart';
import 'package:customer/utils/colors.dart';
import 'package:customer/view/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class authRegThree extends StatefulWidget {
  const authRegThree({super.key});

  @override
  _authRegThreeState createState() => _authRegThreeState();
}

class _authRegThreeState extends State<authRegThree> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  int? customerId;

  @override
  void initState() {
    super.initState();
    _getCustomerIdFromSharedPreferences();
  }

  Future<void> _getCustomerIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt('tempId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: whiteColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Gender', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        Radio<String>(
                          value: '1',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const Text('Male'),
                        Radio<String>(
                          value: '2',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const Text('Female'),
                        Radio<String>(
                          value: '3',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const Text('Other'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        } else if (!isPasswordCompliant(value)) {
                          return 'Password must contain at least one upper case, one digit, one special character, and be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor),
                        onPressed: _submitForm,
                        child: const Text(
                          'Register',
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool isPasswordCompliant(String password, {String minLength = '8'}) {
    if (password.isEmpty) {
      return false;
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{' +
            minLength +
            r',}$';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(password);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final formData = {
        'id': customerId.toString(),
        'username': _usernameController.text.trim(),
        'gender': _selectedGender!,
        'password': _passwordController.text,
      };

      try {
        final response = await http.patch(
          Uri.parse(Api.regThree), // Replace with your actual API URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print(responseData);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AuthLogin(),
          ));
        } else {
          print(response.body);
          _showErrorDialog('Failed to verify OTP');
        }
      } catch (e) {
        _showErrorDialog('Error verifying OTP: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

      // try {
      //   final response = await http.patch(
      //     Uri.parse(Api.regThree),
      //     body: jsonEncode(formData),
      //   );
      //
      //   print(jsonEncode(formData));
      //
      //   if (response.statusCode == 200) {
      //     Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (context) => AuthLogin(),
      //     ));
      //    // Return to previous screen after successful update
      //   } else {
      //     print(response.statusCode);
      //     print(response.body);
      //     _showErrorDialog('Failed to update customer details');
      //   }
      // } catch (e) {
      //   _showErrorDialog('Error updating customer details: $e');
      // } finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
