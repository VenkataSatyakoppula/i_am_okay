import 'package:flutter/services.dart';

const int kStateInputMaxLength = 30;
const int kStateDisplayMaxLength = 10;
const int kPostalCodeInputMaxLength = 20;

List<TextInputFormatter> postalCodeInputFormatters() => [
      LengthLimitingTextInputFormatter(kPostalCodeInputMaxLength),
    ];

/// For read-only UI; full value remains in models/API.
String? truncateStateForDisplay(String? state) {
  if (state == null || state.isEmpty) return state;
  if (state.length <= kStateDisplayMaxLength) return state;
  return '${state.substring(0, kStateDisplayMaxLength)}...';
}

List<TextInputFormatter> stateFieldInputFormatters() => [
      LengthLimitingTextInputFormatter(kStateInputMaxLength),
    ];
