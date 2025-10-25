<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# AnyField

A flexible Flutter input field widget that can display arbitrary content while maintaining the look and feel of a TextField.

## Features

- 📝 Display any custom content within an input field
- 🎨 Full support for InputDecoration (labels, borders, icons)
- 📏 Configurable height constraints with scroll support
- 🔄 Value management through controller pattern
- 🖱️ Tap handling for custom interaction
- ⌨️ Keyboard navigation support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  any_field: ^1.0.0
```

## Usage

### Basic Example

```dart
AnyField<List<String>>(
  displayBuilder: (context, tags) => Wrap(
    spacing: 4,
    children: tags.map((tag) => Chip(label: Text(tag))).toList(),
  ),
  controller: AnyValueController(['flutter', 'widget']),
  decoration: InputDecoration(
    labelText: 'Tags',
    border: OutlineInputBorder(),
  ),
  onTap: () => _showTagSelector(),
)
```

### With Controller

```dart
final controller = AnyValueController<DateTime>(
  DateTime.now(),
  shouldNotify: (prev, curr) => prev.day != curr.day,
);

AnyField<DateTime>(
  displayBuilder: (context, date) => Text(
    DateFormat.yMMMd().format(date),
  ),
  controller: controller,
  decoration: InputDecoration(
    labelText: 'Date',
    suffixIcon: Icon(Icons.calendar_today),
  ),
  onTap: () async {
    final date = await showDatePicker(...);
    if (date != null) {
      controller.value = date;
    }
  },
)
```

## API Reference

### AnyField

| Parameter | Type | Description |
|-----------|------|-------------|
| `displayBuilder` | `Widget Function(BuildContext, T)` | Builds the content display |
| `decoration` | `InputDecoration` | Standard input decoration |
| `minHeight` | `double?` | Minimum field height |
| `maxHeight` | `double?` | Maximum field height |
| `displayPadding` | `EdgeInsets?` | Padding around content |
| `controller` | `AnyValueController<T>?` | Value controller |
| `onChanged` | `ValueChanged<T?>?` | Value change callback |
| `onTap` | `void Function(T? value)?` | Tap handler with current value |
| `herlperHeightCompensation` | `double?` | Height adjustment for helper text (default: 21) |
| `errorHeightCompensation` | `double?` | Height adjustment for error text (default: 21) |
| `floatingLabelHeightCompensation` | `double?` | Height adjustment for floating label (default: 0) |
| `leftCompensation` | `double?` | Additional left padding (default: 0) |
| `rightCompensation` | `double?` | Additional right padding (default: 0) |

### AnyValueController

Controller for managing field values.

```dart
// Create with initial value
final controller = AnyValueController<int>(42);

// Create empty
final controller = AnyValueController<String>.empty();

// With custom change detection
final controller = AnyValueController<List>(
  [],
  shouldNotify: (prev, curr) => prev.length != curr.length,
);
```

## Form Integration

AnyField can be used within forms using the `AnyFormField` wrapper:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      AnyFormField<DateTime>(
        displayBuilder: (context, date) => 
          Text(DateFormat.yMMMd().format(date)),
        decoration: InputDecoration(
          labelText: 'Event Date',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (value == null) return 'Please select a date';
          if (value.isBefore(DateTime.now())) {
            return 'Date must be in the future';
          }
          return null;
        },
        onSaved: (value) => _eventDate = value,
        onTap: (currentDate) async {
          final date = await showDatePicker(
            context: context,
            initialDate: currentDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2025),
          );
          if (date != null) {
            // Form field handles controller internally
            return date;
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Handle saved data
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### AnyFormField API

| Parameter | Type | Description |
|-----------|------|-------------|
| `displayBuilder` | `Widget Function(BuildContext, T)` | Builds the content display |
| `decoration` | `InputDecoration` | Input decoration (shows validation errors) |
| `minHeight` | `double?` | Minimum field height |
| `maxHeight` | `double?` | Maximum field height |
| `displayPadding` | `EdgeInsets?` | Padding around content |
| `initialValue` | `T?` | Initial value when no controller provided |
| `controller` | `AnyValueController<T>?` | Optional external controller |
| `validator` | `FormFieldValidator<T>?` | Form validation function |
| `onSaved` | `FormFieldSetter<T>?` | Called when form is saved |
| `onChanged` | `ValueChanged<T?>?` | Value change callback |
| `onTap` | `Future<T?> Function(T? value)?` | Async tap handler returning new value |
| `herlperHeightCompensation` | `double?` | Height adjustment for helper text (default: 21) |
| `errorHeightCompensation` | `double?` | Height adjustment for error text (default: 21) |
| `floatingLabelHeightCompensation` | `double?` | Height adjustment for floating label (default: 0) |
| `leftCompensation` | `double?` | Additional left padding (default: 0) |
| `rightCompensation` | `double?` | Additional right padding (default: 0) |

## Additional Information

- Works with any value type through generics
- Supports keyboard focus and navigation
- Automatically handles scroll when content exceeds maxHeight
- Compatible with Form widgets and validation

## License

MIT License - see the [LICENSE](LICENSE) file for details
