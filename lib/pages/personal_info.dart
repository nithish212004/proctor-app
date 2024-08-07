import 'package:flutter/material.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/widgets/form_field.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  bool isloading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _namecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), child: 
    SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Name', 
              controller: _namecontroller,
              icon: Icons.align_horizontal_left_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your register number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Register Number', 
              controller: _namecontroller,
              icon: Icons.numbers
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your roll number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Roll Number', 
              controller: _namecontroller,
              icon: Icons.numbers
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your phone number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Phone Number', 
              controller: _namecontroller,
              icon: Icons.phone
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your email';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Email', 
              controller: _namecontroller,
              icon: Icons.mail
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your date of birth';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Date of Birth (DD - MM - YYYY)', 
              controller: _namecontroller,
              icon: Icons.date_range
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter the gender';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Gender (M / F)', 
              controller: _namecontroller,
              icon: Icons.person
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your caste';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Caste', 
              controller: _namecontroller,
              icon: Icons.app_registration_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your community';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Community', 
              controller: _namecontroller,
              icon: Icons.app_registration_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your religion';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Religion', 
              controller: _namecontroller,
              icon: Icons.app_registration_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your aadhar number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Aadhar Number', 
              controller: _namecontroller,
              icon: Icons.numbers_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your blood group';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Blood Group (AB +ve)', 
              controller: _namecontroller,
              icon: Icons.bloodtype_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your address';
                }
                return null;
              }, 
              textInputAction: TextInputAction.newline, 
              label: 'Address', 
              controller: _namecontroller,
              icon: Icons.share_location_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your state';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'State', 
              controller: _namecontroller,
              icon: Icons.location_on_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your nationality';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Nationality', 
              controller: _namecontroller,
              icon: Icons.my_location
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your father\'s name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Father\'s Name', 
              controller: _namecontroller,
              icon: Icons.align_horizontal_left_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your father\'s occupation';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Father\'s Occupation', 
              controller: _namecontroller,
              icon: Icons.work
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your father\'s number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Father\'s Number', 
              controller: _namecontroller,
              icon: Icons.phone
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your mother\'s name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Mother\'s Name', 
              controller: _namecontroller,
              icon: Icons.align_horizontal_left_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your mother\'s occupation';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Mother\'s Occupation', 
              controller: _namecontroller,
              icon: Icons.work
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your mother\'s number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Mother\'s Number', 
              controller: _namecontroller,
              icon: Icons.phone
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your family\'s annual income';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Family\'s Annual Income', 
              controller: _namecontroller,
              icon: Icons.currency_rupee_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter the first graduate status';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'First Graduate Status (Y / N)', 
              controller: _namecontroller,
              icon: Icons.book
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter the bank name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Bank Name', 
              controller: _namecontroller,
              icon: Icons.account_balance_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your bank account name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Bank Account Name', 
              controller: _namecontroller,
              icon: Icons.align_horizontal_left_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your bank account number';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Bank Account Number', 
              controller: _namecontroller,
              icon: Icons.numbers
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your bank account\'s branch name';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'Branch Name', 
              controller: _namecontroller,
              icon: Icons.align_horizontal_left_rounded
            ),
            CustomFormField(
              isloading: isloading, 
              textInputType: TextInputType.name, 
              validator: (val) {
                if(val != null && val.isEmpty){
                  return 'Please enter your bank account\'s IFSC code';
                }
                return null;
              }, 
              textInputAction: TextInputAction.next, 
              label: 'IFSC Code', 
              controller: _namecontroller,
              icon: Icons.code
            ),
            const SizedBox(height: 40,),
            InkWell(
                          onTap: () async {
                            if (_formkey.currentState!.validate()) {
                              
                              setState(() {
                                isloading = false;
                              });
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 50,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 40,
                  ),
          ],
        ),
      ),
    )
    );
  }
}