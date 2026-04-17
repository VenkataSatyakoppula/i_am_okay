import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config.dart';
import '../constants/countries.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../services/graphql_service.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../utils/api_error_handler.dart';
import '../utils/phone_input_formatter.dart';
import '../utils/phone_display_helper.dart';
import '../utils/name_validator.dart';
import 'daily_reminder_screen.dart';

class EmergencyContactScreen extends StatefulWidget {
  final bool isOnboarding;

  const EmergencyContactScreen({
    super.key,
    this.isOnboarding = true,
  });

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isFormVisible = true;
  final List<Map<String, dynamic>> _contacts = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Track which contact is being edited. Null means adding a new contact.
  int? _editingIndex;
  bool _hasConsented = false;
  /// User selects either SMS or WhatsApp, not both.
  String _selectedChannel = 'sms';
  CountryOption _selectedContactCountry = defaultCountryForLocale(
    WidgetsBinding.instance.platformDispatcher.locale,
  );

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _applyContactsFromUser(User user) {
    if (user.emergencyContacts.isEmpty) return;
    _contacts.clear();
    _contacts.addAll(user.emergencyContacts.map((c) {
      final whatsAppOnly = _isWhatsAppOnly(c);
      return {
        'name': c.name ?? '',
        'relation': _normalizeRelation(c.relation),
        'phone': c.phone ?? '',
        'phoneExt': c.phoneExt ?? AppConfig.defaultPhoneExt,
        'email': c.email,
        'smsOptIn': c.smsOptIn ?? true,
        'smsEnabled': c.smsEnabled ?? false,
        'whatsAppEnabled': c.whatsAppEnabled ?? false,
        'sendViaSms': !whatsAppOnly,
        'sendViaWhatsApp': whatsAppOnly,
      };
    }));
    _isFormVisible = _contacts.isEmpty;
  }

  Future<void> _fetchContacts() async {
    try {
      // Show cached contacts immediately so no spinner when navigating
      final cachedUser = await GraphQLService.getCachedUser();
      if (mounted && cachedUser != null) {
        setState(() {
          if (cachedUser.emergencyContacts.isNotEmpty) {
            _applyContactsFromUser(cachedUser);
          }
          _isFormVisible = _contacts.isEmpty;
          _isLoading = false;
        });
      }

      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        if (mounted && _isLoading) setState(() => _isLoading = false);
        return;
      }

      final user = await GraphQLService.getUser(userId);
      if (mounted && user != null) {
        setState(() {
          _contacts.clear();
          _applyContactsFromUser(user);
        });
      }
    } catch (e) {
      if (mounted) await ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _selectedRelation;

  final List<String> _relations = [
    'Parent',
    'Spouse',
    'Child',
    'Sibling',
    'Friend',
    'Partner',
    'Other'
  ];

  String _normalizeRelation(String? relation) {
    if (relation == null || relation.isEmpty) return 'Other';
    return _relations.contains(relation) ? relation : 'Other';
  }

  String _localizedRelation(AppLocalizations l10n, String? relation) {
    if (relation == null || relation.isEmpty) return l10n.relationOther;
    switch (relation) {
      case 'Parent': return l10n.relationParent;
      case 'Spouse': return l10n.relationSpouse;
      case 'Child': return l10n.relationChild;
      case 'Sibling': return l10n.relationSibling;
      case 'Friend': return l10n.relationFriend;
      case 'Partner': return l10n.relationPartner;
      default: return l10n.relationOther;
    }
  }

  /// True if contact uses WhatsApp only (sendViaWhatsApp true, sendViaSms false).
  bool _isWhatsAppOnly(EmergencyContact c) {
    return (c.sendViaWhatsApp ?? false) && !(c.sendViaSms ?? true);
  }

  /// Builds badge for user's channel selection (SMS or WhatsApp, mutually exclusive).
  List<Widget> _buildChannelBadges(AppLocalizations l10n, Map<String, dynamic> contact) {
    final sendViaWhatsApp = contact['sendViaWhatsApp'] == true;
    final isSms = !sendViaWhatsApp;
    return [
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSms
              ? const Color(0xFF1F4ED8).withValues(alpha: 0.12)
              : const Color(0xFF25D366).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSms ? const Color(0xFF1F4ED8) : const Color(0xFF25D366),
            width: 1,
          ),
        ),
        child: Text(
          isSms ? l10n.sms : l10n.whatsApp,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSms ? const Color(0xFF1F4ED8) : const Color(0xFF128C7E),
          ),
        ),
      ),
    ];
  }

  /// Builds a prominent opt-in status indicator for older users.
  Widget _buildOptInStatus(AppLocalizations l10n, Map<String, dynamic> contact) {
    final sendViaWhatsApp = contact['sendViaWhatsApp'] == true;
    final optedIn = sendViaWhatsApp
        ? (contact['whatsAppEnabled'] == true)
        : (contact['smsEnabled'] == true);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: optedIn
              ? const Color(0xFF16A34A).withValues(alpha: 0.12)
              : const Color(0xFFF59E0B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: optedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              optedIn ? Icons.check_circle : Icons.schedule,
              size: 22,
              color: optedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                optedIn
                    ? l10n.readyToReceiveAlerts
                    : l10n.waitingForConfirmation,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: optedIn ? const Color(0xFF15803D) : const Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBackend({bool showSuccessMessage = true}) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return;

      final contactsToUpdate = _contacts.map((c) {
        final rawPhone = c['phone'].toString();
        final phone = rawPhone.replaceAll(RegExp(r'\D'), '');
        return {
          'name': c['name'],
          'relation': c['relation'],
          'phone': phone,
          'phoneExt': c['phoneExt'] ?? AppConfig.defaultPhoneExt,
          'email': (c['email'] == null || c['email'].toString().isEmpty)
              ? null
              : c['email'],
          'smsOptIn': c['smsOptIn'] == true,
          'smsEnabled': c['smsEnabled'] == true,
          'whatsAppEnabled': c['whatsAppEnabled'] == true,
          'sendViaSms': c['sendViaWhatsApp'] != true,
          'sendViaWhatsApp': c['sendViaWhatsApp'] == true,
        };
      }).toList();

      await GraphQLService.updateUser(userId, {
        'emergencyContacts': contactsToUpdate,
      });

      if (!mounted || !showSuccessMessage) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (e is OperationException && e.graphqlErrors.isNotEmpty) {
        final errMsg = e.graphqlErrors.first.message;
        if (errMsg.contains('CHANNEL_REQUIRED') ||
            errMsg.contains('at least one channel')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Each emergency contact must have at least one channel (SMS or WhatsApp) selected.',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
      await ApiErrorHandler.handle(context, e);
    }
  }

  bool _saveContact() {
    // If adding new, check limit
    if (_editingIndex == null && _contacts.length >= 3) return false;
    
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (!_hasConsented) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseConfirmConsent ?? 'Please confirm that the contact has consented to receive alerts.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final inputPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    // Check for duplicates
    for (int i = 0; i < _contacts.length; i++) {
      // Skip if we are editing this specific contact
      if (_editingIndex != null && i == _editingIndex) continue;

      final existingPhone = _contacts[i]['phone'].toString().replaceAll(RegExp(r'\D'), '');
      
      if (existingPhone == inputPhone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This phone number is already added as an emergency contact.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    final sendViaSms = _selectedChannel == 'sms';
    final newContact = {
      'relation': _selectedRelation!,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'phoneExt': _selectedContactCountry.phoneExt,
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'smsOptIn': _hasConsented,
      'smsEnabled': false,
      'whatsAppEnabled': false,
      'sendViaSms': sendViaSms,
      'sendViaWhatsApp': !sendViaSms,
    };

    setState(() {
      if (_editingIndex != null) {
        // Update existing; preserve smsEnabled, whatsAppEnabled (read-only from backend)
        final existing = _contacts[_editingIndex!];
        _contacts[_editingIndex!] = {
          ...newContact,
          'smsEnabled': existing['smsEnabled'] ?? false,
          'whatsAppEnabled': existing['whatsAppEnabled'] ?? false,
          'phoneExt': _selectedContactCountry.phoneExt,
        };
        _editingIndex = null;
      } else {
        // Add new
        _contacts.add(newContact);
      }

      // Reset form
      _selectedRelation = null;
      _selectedContactCountry = defaultCountryForLocale(
        WidgetsBinding.instance.platformDispatcher.locale,
      );
      _selectedChannel = 'sms';
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _hasConsented = false;
      _isFormVisible = false;
    });
    
    // Auto-save
    _updateBackend();
    
    return true;
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
      // If we were editing this specific contact, cancel edit
      if (_editingIndex == index) {
        _editingIndex = null;
        _isFormVisible = false;
        _selectedRelation = null;
        _selectedChannel = 'sms';
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _hasConsented = false;
      } else if (_editingIndex != null && _editingIndex! > index) {
        // Adjust index if we removed a contact before the one being edited
        _editingIndex = _editingIndex! - 1;
      }

      if (_contacts.isEmpty) {
        _isFormVisible = true;
      }
    });
    // Auto-save
    _updateBackend();
  }

  void _editContact(int index) {
    final contact = _contacts[index];
    final ext = contact['phoneExt']?.toString() ?? AppConfig.defaultPhoneExt;
    final country = supportedCountries.firstWhere(
      (c) => c.phoneExt == ext,
      orElse: () => supportedCountries.first,
    );
    setState(() {
      _editingIndex = index;
      _nameController.text = contact['name'];

      // Show national number only in phone field; country is in the Country dropdown
      String rawPhone = contact['phone']?.toString() ?? '';
      _phoneController.text = formatPhoneNational(rawPhone);

      _emailController.text = contact['email'] ?? '';
      _selectedRelation = _normalizeRelation(contact['relation']?.toString());
      _selectedContactCountry = country;

      _hasConsented = contact['smsOptIn'] == true;
      _selectedChannel = (contact['sendViaWhatsApp'] == true) ? 'whatsapp' : 'sms';
      _isFormVisible = true;
    });
  }

  Future<void> _handleNext() async {
    // For Onboarding:
    // If form is visible and has data, user might have forgotten to click "Add".
    // We try to add it. If it fails validation, we stop.
    if (_isFormVisible &&
        (_nameController.text.isNotEmpty ||
            _phoneController.text.isNotEmpty ||
            _selectedRelation != null)) {
      if (!_saveContact()) {
        return;
      }
    }

    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one emergency contact'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isFormVisible = true;
      });
      return;
    }

    // Since we auto-save, we just navigate.
    // If not onboarding (e.g. settings), we don't need this method unless it's a "Done" button?
    // User requested "remove save button in contacts screen".
    // So this is mainly for Onboarding "Next".
    
    if (widget.isOnboarding) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const DailyReminderScreen()),
      );
    } else {
      // Just a fallback if this is called in non-onboarding mode
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: widget.isOnboarding
          ? AppBar(
              backgroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              title: Text(
                AppLocalizations.of(context)!.emergencyContacts,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF1F4ED8)),
                  onPressed: _isLoading ? null : () => _fetchContacts(),
                  tooltip: AppLocalizations.of(context)!.refresh,
                ),
              ],
            )
          : null, // Hide AppBar when inside TabBar as the TabBar wrapper might provide it or it's not needed
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchContacts,
                color: const Color(0xFF1F4ED8),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addUpTo3Contacts(_contacts.length),
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF1F4ED8)),
                    onPressed: () => _fetchContacts(),
                    tooltip: l10n.refresh,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // List of added contacts
              if (_contacts.isNotEmpty) ...[
                ..._contacts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contact = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      contact['name']!,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ..._buildChannelBadges(l10n, contact),
                                ],
                              ),
                              Text(
                                '${_localizedRelation(l10n, contact['relation']?.toString())} • ${formatPhoneDisplay(contact['phone'].toString(), contact['phoneExt']?.toString())}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              _buildOptInStatus(l10n, contact),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF1F4ED8)),
                              onPressed: () => _editContact(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeContact(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Add Contact Form (show when under 3 contacts or when editing one)
              if (_contacts.length < 3 || _editingIndex != null) ...[
                if (_isFormVisible)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                        Text(
                          _editingIndex != null ? l10n.editContact : l10n.addNewContact,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField<String>(
                          label: l10n.relation,
                          hint: l10n.hintSelectRelation,
                          value: _selectedRelation != null ? _normalizeRelation(_selectedRelation) : null,
                          items: _relations.map((String relation) {
                            return DropdownMenuItem<String>(
                              value: relation,
                              child: Text(_localizedRelation(l10n, relation)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRelation = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? l10n.pleaseSelectRelation : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: l10n.fullName,
                          hint: l10n.hintFullName,
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_phoneFocus),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.validationNameRequired;
                            }
                            if (!validNamePattern.hasMatch(value)) {
                              return l10n.validationOnlyAlphabets;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField<CountryOption>(
                          label: l10n.country,
                          hint: l10n.hintSelectCountry,
                          value: _selectedContactCountry,
                          items: supportedCountries
                              .map((c) => DropdownMenuItem<CountryOption>(
                                    value: c,
                                    child: Text(c.displayLabel),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedContactCountry = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: l10n.phoneNumber,
                          hint: l10n.hintPhoneNumber,
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          readOnly: _editingIndex != null &&
                              (_contacts[_editingIndex!]['smsEnabled'] == true),
                          inputFormatters: [PhoneInputFormatter()],
                          focusNode: _phoneFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_emailFocus),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.validationPhoneRequired;
                            }
                            final digits =
                                value.replaceAll(RegExp(r'\D'), '');
                            if (digits.length < 8 || digits.length > 12) {
                              return l10n.validationPhone10Digits;
                            }
                            return null;
                          },
                        ),
                        if (_editingIndex != null &&
                            (_contacts[_editingIndex!]['smsEnabled'] == true))
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              l10n.phoneCannotChange,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: l10n.email,
                          hint: l10n.hintContactEmail,
                          keyboardType: TextInputType.emailAddress,
                          isOptional: true,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _saveContact(),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                              if (!emailRegex.hasMatch(value)) {
                                return l10n.validationEmailInvalid;
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.sendAlertsVia,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ChannelCard(
                                label: l10n.sms,
                                icon: Icon(Icons.sms_outlined, size: 32, color: const Color(0xFF1F4ED8)),
                                isSelected: _selectedChannel == 'sms',
                                onTap: () => setState(() => _selectedChannel = 'sms'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ChannelCard(
                                label: l10n.whatsApp,
                                icon: FaIcon(FontAwesomeIcons.whatsapp, size: 32, color: const Color(0xFF25D366)),
                                isSelected: _selectedChannel == 'whatsapp',
                                onTap: () => setState(() => _selectedChannel = 'whatsapp'),
                                accentColor: const Color(0xFF25D366),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            _selectedChannel == 'sms'
                                ? '${l10n.consentDisclaimerBase}\n\n${l10n.consentDisclaimerSmsRates}'
                                : l10n.consentDisclaimerBase,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _hasConsented,
                                onChanged: (value) {
                                  setState(() {
                                    _hasConsented = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF1F4ED8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _hasConsented = !_hasConsented;
                                  });
                                },
                                child: Text(
                                  _selectedChannel == 'sms'
                                      ? l10n.consentCheckboxSms
                                      : l10n.consentCheckboxWhatsApp,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: _editingIndex != null ? l10n.updateContact : l10n.addContact,
                          onPressed: _hasConsented ? _saveContact : null,
                          backgroundColor: Colors.transparent,
                          textColor: const Color(0xFF1F4ED8),
                        ),
                        const Divider(height: 48),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else ...[
                  Builder(
                    builder: (context) => CustomButton(
                      text: AppLocalizations.of(context)?.addAnotherContact ?? 'Add Another Contact',
                    onPressed: () {
                      setState(() {
                        _isFormVisible = true;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    textColor: const Color(0xFF1F4ED8),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],

              if (widget.isOnboarding) ...[
                Builder(
                  builder: (context) => CustomButton(
                    text: AppLocalizations.of(context)?.next ?? 'Next',
                  onPressed: _handleNext,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // "Save" button removed as per request for auto-save logic.
              // We only keep "Next" for onboarding flow.
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

/// Selectable card for SMS/WhatsApp channel selection. Larger touch target for accessibility.
class _ChannelCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _ChannelCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? (accentColor ?? const Color(0xFF1F4ED8))
        : const Color(0xFFE5E7EB);
    final bgColor = isSelected
        ? (accentColor ?? const Color(0xFF1F4ED8)).withValues(alpha: 0.08)
        : const Color(0xFFFAFAFA);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
