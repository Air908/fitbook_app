// features/search/widgets/advanced_search_filter.dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class AdvancedSearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedSearchFilter({
    Key? key,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Filter Facilities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _formKey.currentState?.reset(),
                  child: const Text('Clear All'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Facility Type
            FormBuilderDropdown<String>(
              name: 'facility_type',
              decoration: const InputDecoration(
                labelText: 'Facility Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'gym', child: Text('Gym')),
                DropdownMenuItem(value: 'swimming_pool', child: Text('Swimming Pool')),
                DropdownMenuItem(value: 'sports_turf', child: Text('Sports Turf')),
                DropdownMenuItem(value: 'yoga_studio', child: Text('Yoga Studio')),
              ],
            ),

            const SizedBox(height: 16),

            // Price Range
            FormBuilderRangeSlider(
              name: 'price_range',
              decoration: const InputDecoration(
                labelText: 'Price Range (₹/hour)',
              ),
              min: 0,
              max: 5000,
              divisions: 50,
              initialValue: const RangeValues(0, 5000),
              numberFormat: NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
                decimalDigits: 0,
              ),
            ),

            const SizedBox(height: 16),

            // Distance
            FormBuilderSlider(
              name: 'distance',
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
              ),
              min: 1,
              max: 50,
              divisions: 49,
              initialValue: 10,
              numberFormat: NumberFormat('#0 km'),
            ),

            const SizedBox(height: 16),

            // Rating
            FormBuilderSlider(
              name: 'min_rating',
              decoration: const InputDecoration(
                labelText: 'Minimum Rating',
              ),
              min: 1,
              max: 5,
              divisions: 8,
              initialValue: 1,
              numberFormat: NumberFormat('#0.0'),
            ),

            const SizedBox(height: 16),

            // Amenities
            FormBuilderCheckboxGroup<String>(
              name: 'amenities',
              decoration: const InputDecoration(
                labelText: 'Amenities',
              ),
              options: const [
                FormBuilderFieldOption(value: 'parking', child: Text('Parking')),
                FormBuilderFieldOption(value: 'wifi', child: Text('Wi-Fi')),
                FormBuilderFieldOption(value: 'locker', child: Text('Lockers')),
                FormBuilderFieldOption(value: 'shower', child: Text('Shower')),
                FormBuilderFieldOption(value: 'ac', child: Text('Air Conditioning')),
                FormBuilderFieldOption(value: 'equipment', child: Text('Equipment Rental')),
              ],
              wrapSpacing:  0.0
            ),

            const SizedBox(height: 24),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final filters = _formKey.currentState!.value;
                    widget.onFiltersApplied(filters);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}