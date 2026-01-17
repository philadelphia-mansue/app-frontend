import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';

/// Represents a country with its dial code and flag
class Country {
  final String code;
  final String name;
  final String dialCode;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
  });

  static const italy = Country(
    code: 'IT',
    name: 'Italy',
    dialCode: '+39',
    flag: '🇮🇹',
  );

  static const romania = Country(
    code: 'RO',
    name: 'Romania',
    dialCode: '+40',
    flag: '🇷🇴',
  );

  static const List<Country> supported = [italy, romania];
}

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onSubmit;
  final Country selectedCountry;
  final ValueChanged<Country>? onCountryChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmit,
    this.selectedCountry = Country.italy,
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: l10n.phoneNumber,
        hintText: selectedCountry == Country.italy ? '3XX XXX XXXX' : '7XX XXX XXX',
        prefixIcon: _CountryPicker(
          selectedCountry: selectedCountry,
          onCountryChanged: onCountryChanged,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSubmitted: (_) => onSubmit?.call(),
    );
  }
}

class _CountryPicker extends StatelessWidget {
  final Country selectedCountry;
  final ValueChanged<Country>? onCountryChanged;

  const _CountryPicker({
    required this.selectedCountry,
    this.onCountryChanged,
  });

  String _getLocalizedCountryName(BuildContext context, Country country) {
    final l10n = AppLocalizations.of(context)!;
    switch (country.code) {
      case 'IT':
        return l10n.countryItaly;
      case 'RO':
        return l10n.countryRomania;
      default:
        return country.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Country>(
      initialValue: selectedCountry,
      onSelected: onCountryChanged,
      offset: const Offset(0, 48),
      itemBuilder: (context) => Country.supported.map((country) {
        return PopupMenuItem<Country>(
          value: country,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(_getLocalizedCountryName(context, country)),
              const SizedBox(width: 8),
              Text(
                country.dialCode,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedCountry.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              selectedCountry.dialCode,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
