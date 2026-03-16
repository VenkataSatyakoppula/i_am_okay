import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import '../constants/countries.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../services/graphql_service.dart';
import '../utils/phone_input_formatter.dart';
import '../utils/phone_display_helper.dart';
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
  CountryOption _selectedContactCountry = supportedCountries.first;

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
    _contacts.addAll(user.emergencyContacts.map((c) => {
          'name': c.name ?? '',
          'relation': _normalizeRelation(c.relation),
          'phone': c.phone ?? '',
          'phoneExt': c.phoneExt ?? AppConfig.defaultPhoneExt,
          'email': c.email,
          'smsOptIn': c.smsOptIn ?? true,
          'smsEnabled': c.smsEnabled ?? false,
          'whatsAppEnabled': c.whatsAppEnabled ?? false,
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
      // Error fetching contacts
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

  List<Widget> _buildChannelBadges(Map<String, dynamic> contact) {
    final List<Widget> badges = [];
    if (contact['smsEnabled'] == true) {
      badges.add(const SizedBox(width: 8));
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1F4ED8).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1F4ED8), width: 1),
          ),
          child: const Text(
            'SMS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F4ED8),
            ),
          ),
        ),
      );
    }
    if (contact['whatsAppEnabled'] == true) {
      badges.add(const SizedBox(width: 8));
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF25D366), width: 1),
          ),
          child: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF128C7E),
            ),
          ),
        ),
      );
    }
    return badges;
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
        };
      }).toList();

      await GraphQLService.updateUser(userId, {
        'emergencyContacts': contactsToUpdate,
      });

      if (mounted && showSuccessMessage) {
        final scaffoldContext = _scaffoldKey.currentContext;
        if (scaffoldContext != null) {
          ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            const SnackBar(
              content: Text('Contacts updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        final scaffoldContext = _scaffoldKey.currentContext;
        if (scaffoldContext != null) {
          final message = _contacts.isEmpty
              ? 'Could not clear all contacts. Please check your connection or try again.'
              : 'Failed to sync contacts. Please check your connection.';
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  bool _saveContact() {
    // If adding new, check limit
    if (_editingIndex == null && _contacts.length >= 3) return false;
    
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (!_hasConsented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that the contact has consented to receive SMS alerts.'),
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

    final newContact = {
      'relation': _selectedRelation!,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'phoneExt': _selectedContactCountry.phoneExt,
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'smsOptIn': _hasConsented,
      'smsEnabled': false,
      'whatsAppEnabled': false,
    };

    setState(() {
      if (_editingIndex != null) {
        // Update existing; preserve smsEnabled, whatsAppEnabled, phoneExt (read-only from backend)
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
      _selectedContactCountry = supportedCountries.first;
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
              title: const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            )
          : null, // Hide AppBar when inside TabBar as the TabBar wrapper might provide it or it's not needed
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Text(
                'Add up to 3 emergency contacts (${_contacts.length}/3)',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF333333),
                ),
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
                                  ..._buildChannelBadges(contact),
                                ],
                              ),
                              Text(
                                '${contact['relation']} • ${formatPhoneDisplay(contact['phone'].toString(), contact['phoneExt']?.toString())}',
                                overflow: TextOverflow.ellipsis,
                              ),
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
                        Text(
                          _editingIndex != null ? 'Edit Contact' : 'Add New Contact',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField<String>(
                          label: 'Relation',
                          hint: 'Select relation',
                          value: _selectedRelation != null ? _normalizeRelation(_selectedRelation) : null,
                          items: _relations.map((String relation) {
                            return DropdownMenuItem<String>(
                              value: relation,
                              child: Text(relation),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRelation = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a relation' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'Enter full name',
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_phoneFocus),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Only alphabets are allowed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField<CountryOption>(
                          label: 'Country',
                          hint: 'Select country',
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
                          label: 'Phone Number',
                          hint: 'Enter phone number',
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
                              return 'Phone number is required';
                            }
                            final digits =
                                value.replaceAll(RegExp(r'\D'), '');
                            if (digits.length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        if (_editingIndex != null &&
                            (_contacts[_editingIndex!]['smsEnabled'] == true))
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Text(
                              'Phone number cannot be changed for verified contacts.',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          hint: 'Enter email address',
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
                                return 'Enter a valid email address';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Text(
                            'By adding this contact, you confirm they have agreed to receive automated emergency SMS alerts from IamOkay.\n\nMessage frequency varies. Message & data rates may apply.\n\nReply STOP to opt out. Reply HELP for help.',
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
                                child: const Text(
                                  'I confirm this contact has consented to receive SMS alerts from IamOkay.',
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
                          text: _editingIndex != null ? 'Update Contact' : 'Add Contact',
                          onPressed: _hasConsented ? _saveContact : null,
                          backgroundColor: Colors.transparent,
                          textColor: const Color(0xFF1F4ED8),
                        ),
                        const Divider(height: 48),
                      ],
                    ),
                  )
                else ...[
                  CustomButton(
                    text: 'Add Another Contact',
                    onPressed: () {
                      setState(() {
                        _isFormVisible = true;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    textColor: const Color(0xFF1F4ED8),
                  ),
                  const SizedBox(height: 24),
                ],
              ],

              if (widget.isOnboarding) ...[
                CustomButton(
                  text: 'Next',
                  onPressed: _handleNext,
                ),
                const SizedBox(height: 24),
              ],
              // "Save" button removed as per request for auto-save logic.
              // We only keep "Next" for onboarding flow.
            ],
          ),
        ),
      ),
    );
  }
}
