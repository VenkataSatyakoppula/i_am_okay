import 'package:flutter/material.dart';
import 'package:IamOkay/models/user_model.dart';
import 'package:IamOkay/services/graphql_service.dart';
import 'package:IamOkay/widgets/custom_button.dart';
import 'package:IamOkay/widgets/custom_text_field.dart';
import 'package:IamOkay/utils/api_error_handler.dart';
import 'package:IamOkay/utils/name_validator.dart';
import 'package:IamOkay/utils/state_field.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
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
  final _aliasController = TextEditingController();
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _stateController;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _aliasFocus = FocusNode();
  final _address1Focus = FocusNode();
  final _address2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _zipCodeFocus = FocusNode();
  final _stateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.name?.firstName);
    _lastNameController = TextEditingController(text: widget.user.name?.lastName);
    _aliasController.text = widget.user.name?.alias ?? '';
    _address1Controller = TextEditingController(text: widget.user.address?.address1);
    _address2Controller = TextEditingController(text: widget.user.address?.address2);
    _cityController = TextEditingController(text: widget.user.address?.city);
    final stateRaw = widget.user.address?.state ?? '';
    _stateController = TextEditingController(
      text: stateRaw.length > kStateInputMaxLength
          ? stateRaw.substring(0, kStateInputMaxLength)
          : stateRaw,
    );
    final zipRaw = widget.user.address?.zipCode ?? '';
    final zipCapped = zipRaw.length > kPostalCodeInputMaxLength
        ? zipRaw.substring(0, kPostalCodeInputMaxLength)
        : zipRaw;
    _zipCodeController = TextEditingController(text: zipCapped);
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
    _stateController.dispose();
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
          'state': _stateController.text.trim(),
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
        await ApiErrorHandler.handle(context, e);
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
        title: Builder(
          builder: (context) => Text(
            AppLocalizations.of(context)?.editProfile ?? 'Edit Profile',
            style: const TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                CustomTextField(
                  label: l10n.firstName,
                  hint: l10n.hintFirstName,
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationFirstNameRequired;
                    }
                    if (!validNamePattern.hasMatch(value)) {
                      return l10n.validationOnlyAlphabets;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: l10n.lastName,
                  hint: l10n.hintLastName,
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_aliasFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationLastNameRequired;
                    }
                    if (!validNamePattern.hasMatch(value)) {
                      return l10n.validationOnlyAlphabets;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: l10n.aliasName,
                  hint: l10n.hintAliasName,
                  controller: _aliasController,
                  isOptional: true,
                  focusNode: _aliasFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_address1Focus),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !validNamePattern.hasMatch(value)) {
                      return l10n.validationOnlyAlphabets;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: l10n.addressLine1,
                  hint: l10n.hintAddressLine1,
                  controller: _address1Controller,
                  keyboardType: TextInputType.streetAddress,
                  focusNode: _address1Focus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_address2Focus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationAddressRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: l10n.addressLine2,
                  hint: l10n.hintAddressLine2,
                  controller: _address2Controller,
                  isOptional: true,
                  focusNode: _address2Focus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  label: l10n.city,
                  hint: l10n.hintCity,
                  controller: _cityController,
                  focusNode: _cityFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_zipCodeFocus),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationCityRequired;
                    }
                    if (!validNamePattern.hasMatch(value)) {
                      return l10n.validationOnlyAlphabets;
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
                        label: l10n.zipCode,
                        hint: l10n.hintZipCode,
                        keyboardType: TextInputType.streetAddress,
                        inputFormatters: postalCodeInputFormatters(),
                        controller: _zipCodeController,
                        focusNode: _zipCodeFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_stateFocus),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationZipRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: l10n.state,
                        hint: l10n.hintSelectState,
                        controller: _stateController,
                        focusNode: _stateFocus,
                        textInputAction: TextInputAction.done,
                        inputFormatters: stateFieldInputFormatters(),
                        onSubmitted: (_) => _handleUpdate(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseSelectState;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),
                CustomButton(
                  text: l10n.saveChanges,
                  onPressed: _handleUpdate,
                ),
                const SizedBox(height: 24.0),
              ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
