// ignore_for_file: empty_statements

import 'package:chatapp/constants/colors.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import '../providers/user_data_provider.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String countryCode = "+256";

  void handleOtpSubmit(String userId, BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      loginWithOtp(otp: _otpController.text, userId: userId).then((value){
        if(value) {
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserId(userId);

          Provider.of<UserDataProvider>(context, listen: false)
              .setUserPhone(countryCode + _phoneNumberController.text);

          Navigator.pushNamedAndRemoveUntil(context, "/update", (route) => false, arguments: {"title": "add"});
        }
        else{
          ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login Failed")));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(child: Image.asset(
                "images/chat.png",
              fit: BoxFit.cover,
              )),
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                    "welcome to heyi.chat", 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                   ),
                 ],
               ),
             ),
             const Text(
              "Enter your phone number to continue.", 
             ),
             const SizedBox(
              height: 20,
             ),
             Form(
                key: _formKey,
              child: TextFormField(
                controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.length != 9) {
                  return "invalid phone number";
                }
                return null; 
              },
                decoration:  InputDecoration(
                  prefixIcon: CountryCodePicker(
                    onChanged: (value) {
                      print(value.dialCode);
                      countryCode=value.dialCode!;
                    },
                    initialSelection: "UG",
                  ),
                  labelText: "Enter your phone number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
             )),
             const SizedBox(height: 20,),
             SizedBox(
              height: 50, 
              width: double.infinity,
               child: ElevatedButton(
                child: const Text("send OTP"),
             onPressed: () {
              if(_formKey.currentState!.validate()){
                createPhoneSession(
                    phone:
                    countryCode+_phoneNumberController.text).
                    then((value) {
                      if(value!="login_error") {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  backgroundColor: Colors.grey,
                                  title: const Text("OTP Verification"),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("Enter the 6 digit OTP"),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Form(key: _formKey1,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _otpController,
                                          validator: (value) {
                                            if(value!.length!=6) return "Invalid OTP";
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              labelText: "Enter the otp recieved",
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12)
                                              )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: (){
                                          handleOtpSubmit(
                                              value, context);
                                        },
                                        child: const Text(
                                            "Submit"
                                        ))
                                  ],
                                ));
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send otp")));
                      }
                });


                showDialog(
                  context: context, 
                  builder: (context) =>
                AlertDialog(
                  backgroundColor: Colors.grey,
                  title: const Text("OTP Verification"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Enter the 6 digit OTP"),
                      const SizedBox(
                        height: 12,
                      ),
                      Form(key: _formKey1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _otpController,
                        validator: (value) {
                          if(value!.length!=6) return "Invalid OTP";
                         return null; 
                        },
                        decoration: InputDecoration(
                          labelText: "Enter the otp recieved",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                      ),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: (){
                        if(_formKey1.currentState!
                         .validate()) {};
                      },
                       child: const Text(
                        "Submit"
                        ))
                  ],
                ));
              }
             },
             style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white
             ),
             ),)
            ],
          ),
        ),
      )
    );
  }
}
