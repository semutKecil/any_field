<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.
-->
# AnyField

[![pub package](https://img.shields.io/pub/v/any_field.svg)](https://pub.dev/packages/any_field) [![Donate on Saweria](https://img.shields.io/badge/Donate-Saweria-orange)](https://saweria.co/hrlns)

A flexible Flutter input field widget that can display arbitrary content while maintaining the look and feel of a TextField.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M81N5IYI)

## Features

- 📝 Display any custom content within an input field
- 🎨 Full support for InputDecoration (labels, borders, icons)
- 📏 Configurable height constraints with scroll support
- 🔄 Value management through controller pattern
- 🖱️ Tap handling for custom interaction
- ⌨️ Keyboard navigation support

## Demo

<!-- Use an HTML img tag to constrain the rendered size of the demo GIF -->
<p align="center">
  <img src="screenshots/sample.gif" alt="AnyField demo" height="400" />
</p>

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  any_field: ^0.0.1
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
  onTap: (current) => _showTagSelector(),
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
  onTap: (current) async {
    final date = await showDatePicker(...);
    if (date != null) controller.value = date;
  },
)
```

## Usage notes

- AnyField `onTap` accepts `FutureOr<void>` handlers. For AnyField the callback should update the controller (the return value is ignored). Example:
```dart
AnyField<DateTime>(
  displayBuilder: (c, date) => Text(date == null ? 'Pick a date' : DateFormat.yMMMd().format(date)),
  controller: controller,
  onTap: (current) async {
    final picked = await showDatePicker(...);
    if (picked != null) controller.value = picked;
  },
)
```

- AnyField is well suited for building picker UI that opens dialogs (date picker, selection dialogs, color pickers, etc.). Use the `onTap` callback to open your dialog and update the controller when the user selects a value.

## Platform & layout notes (compensation parameters)

InputDecoration layout (helper text, error text, floating label) differs between platforms, themes and Flutter versions. To get pixel-perfect alignment you can use the compensation parameters:

- `herlperHeightCompensation` — adjust height when helper text is present (default ~20)
- `errorHeightCompensation` — adjust height when error text is present (default ~20)
- `floatingLabelHeightCompensation` — top offset when floating label is used (default 0)
- `topCompensation` — additional top offset for the display area (default 0)
- `leftCompensation` / `rightCompensation` — horizontal fine tuning to compensate for prefix/suffix and platform differences (default 0)

These values are intentionally exposed because the exact visual metrics are not the same on every platform or theme. Test on your target devices and adjust the compensation values until the display area aligns correctly with your InputDecoration.

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
| `onTap` | `FutureOr<void> Function(T? value)?` | Tap handler (sync or async). Handler should update controller; return value is ignored. |
| `herlperHeightCompensation` | `double?` | Height adjustment for helper text (default: 20) |
| `errorHeightCompensation` | `double?` | Height adjustment for error text (default: 20) |
| `floatingLabelHeightCompensation` | `double?` | Height adjustment for floating label (default: 0) |
| `topCompensation` | `double?` | Extra top offset for content (default: 0) |
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

AnyField can be used within forms using the `AnyFormField` wrapper. Note: `AnyFormField.onTap` uses the same signature as `AnyField` (`FutureOr<void> Function(T? value)?`) — the callback should update the controller or call `onChanged` to apply the selected value.

```dart
final controller = AnyValueController<DateTime?>(null);

Form(
  key: _formKey,
  child: Column(
    children: [
      AnyFormField<DateTime?>(
        controller: controller,
        displayBuilder: (context, date) => 
          Text(date == null ? 'Pick a date' : DateFormat.yMMMd().format(date)),
        decoration: InputDecoration(
          labelText: 'Event Date',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (value == null) return 'Please select a date';
          if (value!.isBefore(DateTime.now())) {
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
            controller.value = date;
          }
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
| `onTap` | `FutureOr<void> Function(T? value)?` | Tap handler (sync or async). Handler should update controller or call onChanged. |
| `herlperHeightCompensation` | `double?` | Height adjustment for helper text (default: 20) |
| `errorHeightCompensation` | `double?` | Height adjustment for error text (default: 20) |
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
