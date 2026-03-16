import 'package:flutter/material.dart';
import 'package:IamOkay/models/user_model.dart';
import 'package:IamOkay/services/graphql_service.dart';
import 'package:IamOkay/widgets/custom_button.dart';
import 'package:IamOkay/widgets/custom_text_field.dart';
import 'package:IamOkay/widgets/custom_dropdown_field.dart';
import 'package:IamOkay/widgets/loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _aliasController = TextEditingController();
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _aliasFocus = FocusNode();
  final _address1Focus = FocusNode();
  final _address2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _zipCodeFocus = FocusNode();
  final _stateFocus = FocusNode();

  String? _selectedState;

  final List<String> _states = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
  ];

  String? _normalizeState(String? state) {
    if (state == null || state.isEmpty) return null;
    return _states.contains(state) ? state : null;
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.name?.firstName);
    _lastNameController = TextEditingController(text: widget.user.name?.lastName);
    _aliasController.text = widget.user.name?.alias ?? '';
    _address1Controller = TextEditingController(text: widget.user.address?.address1);
    _address2Controller = TextEditingController(text: widget.user.address?.address2);
    _cityController = TextEditingController(text: widget.user.address?.city);
    _selectedState = _normalizeState(widget.user.address?.state);
    _zipCodeController = TextEditingController(text: widget.user.address?.zipCode);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aliasController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _aliasFocus.dispose();
    _address1Focus.dispose();
    _address2Focus.dispose();
    _cityFocus.dispose();
    _zipCodeFocus.dispose();
    _stateFocus.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a state'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    LoadingOverlay.show(context);
    try {
      await GraphQLService.updateUser(widget.user.id, {
        'name': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'alias': _aliasController.text.trim(),
        },
        'address': {
          'address1': _address1Controller.text.trim(),
          'address2': _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'zipCode': _zipCodeController.text.trim(),
        },
      });

      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only alphabets are allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_aliasFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only alphabets are allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: 'Alias Name',
                  hint: 'Enter your alias name',
                  controller: _aliasController,
                  isOptional: true,
                  focusNode: _aliasFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_address1Focus),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only alphabets are allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: 'Address Line 1',
                  hint: 'Street address, P.O. box, etc.',
                  controller: _address1Controller,
                  keyboardType: TextInputType.streetAddress,
                  focusNode: _address1Focus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_address2Focus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address Line 1 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: 'Address Line 2',
                  hint: 'Apartment, suite, unit, etc.',
                  controller: _address2Controller,
                  isOptional: true,
                  focusNode: _address2Focus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: 'City',
                  hint: 'Enter your city',
                  controller: _cityController,
                  focusNode: _cityFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_zipCodeFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Only alphabets are allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: 'Zip Code',
                        hint: 'Zip Code',
                        keyboardType: TextInputType.number,
                        controller: _zipCodeController,
                        focusNode: _zipCodeFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_stateFocus),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Zip Code is required';
                          }
                          if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                            return 'Enter a valid 5-digit Zip Code';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: CustomDropdownField<String>(
                        label: 'State',
                        hint: 'Select State',
                        value: _normalizeState(_selectedState),
                        items: _states.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedState = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a state' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _handleUpdate,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
