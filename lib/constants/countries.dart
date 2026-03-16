/// Supported countries for phone/country code selection.
class CountryOption {
  final String name;
  final String phoneExt;
  final String flag;

  const CountryOption({
    required this.name,
    required this.phoneExt,
    required this.flag,
  });

  String get displayLabel => '$flag $name (+$phoneExt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryOption &&
          name == other.name &&
          phoneExt == other.phoneExt &&
          flag == other.flag;

  @override
  int get hashCode => Object.hash(name, phoneExt, flag);
}

const List<CountryOption> supportedCountries = [
  CountryOption(name: 'USA', phoneExt: '1', flag: '🇺🇸'),
  CountryOption(name: 'Canada', phoneExt: '1', flag: '🇨🇦'),
  CountryOption(name: 'India', phoneExt: '91', flag: '🇮🇳'),
  CountryOption(name: 'Kenya', phoneExt: '254', flag: '🇰🇪'),
  CountryOption(name: 'Burkina Faso', phoneExt: '226', flag: '🇧🇫'),
];
