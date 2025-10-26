import 'dart:async';

import 'package:any_field/any_field.dart';
import 'package:flutter/material.dart';

/// A form-enabled wrapper around [AnyField] that provides form integration and validation.
///
/// AnyFormField combines the flexibility of [AnyField] with Flutter's form functionality,
/// allowing it to be used within Form widgets with validation, saving, and error display
/// capabilities.
///
/// Example usage:
/// ```dart
/// Form(
///   key: _formKey,
///   child: AnyFormField<List<String>>(
///     displayBuilder: (context, tags) => Wrap(
///       children: tags.map((t) => Chip(label: Text(t))).toList(),
///     ),
///     decoration: InputDecoration(labelText: 'Tags'),
///     validator: (value) {
///       if (value?.isEmpty ?? true) return 'Please add at least one tag';
///       return null;
///     },
///     onSaved: (value) => _savedTags = value,
///     onTap: (currentTags) async {
///       final result = await showTagSelector(
///         context,
///         initialTags: currentTags ?? []
///       );
///       if (result != null) {
///         // Form field handles controller update
///       }
///     },
///   ),
/// )
/// ```
class AnyFormField<T> extends StatefulWidget {
  /// Function that builds the widget to display the current value.
  ///
  /// Called whenever the field needs to render its content. Receives the current
  /// build context and value of type [T].
  final Widget Function(BuildContext context, T value) displayBuilder;

  /// Decoration to customize the appearance of the field.
  ///
  /// Supports all standard [InputDecoration] properties like labels, hints,
  /// borders, and prefix/suffix widgets. Error text from validation will be
  /// automatically added to this decoration.
  final InputDecoration decoration;

  /// Minimum height of the field in logical pixels.
  ///
  /// If null, the height will be determined by measuring the content.
  final double? minHeight;

  /// Maximum height the field can expand to in logical pixels.
  ///
  /// Content that would cause the field to exceed this height will scroll.
  final double? maxHeight;

  /// Padding applied around the display content within the field.
  final EdgeInsets displayPadding;

  /// Optional controller that manages the field's value.
  ///
  /// If not provided, an internal controller will be created using [initialValue].
  /// The controller will be automatically disposed when the widget is removed
  /// from the tree, unless it was externally provided.
  final AnyValueController<T>? controller;

  /// Initial value for the field when no controller is provided.
  ///
  /// Ignored if a [controller] is specified.
  final T? initialValue;

  /// Callback that is invoked when the field's value changes.
  ///
  /// Receives the new value as parameter.
  final ValueChanged<T?>? onChanged;

  /// Callback that is invoked when the field is tapped.
  ///
  /// This callback receives the current value as a parameter, allowing you to
  /// access the field's value when handling the tap event. Typically used to
  /// show a picker or dialog to modify the value.
  ///
  /// Example:
  /// ```dart
  /// onTap: (currentValue) async {
  ///   final result = await showDialog(
  ///     context: context,
  ///     builder: (_) => SelectionDialog(initialValue: currentValue),
  ///   );
  ///   if (result != null) {
  ///     controller.value = result;
  ///   }
  /// }
  /// ```
  ///
  /// The handler may be synchronous or asynchronous (it is `FutureOr<void>`).
  /// AnyField ignores the return value of this callback; update the controller
  /// from inside the handler to change the field value.
  final FutureOr Function(T? value)? onTap;

  /// Optional validator function called when Form.validate is called.
  ///
  /// Should return null if the value is valid, or an error message string
  /// if validation fails.
  final FormFieldValidator<T>? validator;

  /// Optional callback fired when Form.save is called.
  ///
  /// Use this to persist the field's value when the form is saved.
  final FormFieldSetter<T>? onSaved;

  /// Compensation height in logical pixels for helper text area.
  ///
  /// When helper text is present, this value is used to adjust the display
  /// content position to prevent overlap with the helper area.
  /// Defaults to 20 pixels if not specified.
  final double? herlperHeightCompensation;

  /// Compensation height in logical pixels for error text area.
  ///
  /// When error text is present, this value is used to adjust the display
  /// content position to prevent overlap with the error area.
  /// Defaults to 20 pixels if not specified.
  final double? errorHeightCompensation;

  /// Compensation height in logical pixels for floating label area.
  ///
  /// When using a floating label (InputDecoration.floatingLabelBehavior),
  /// this value adjusts the content position to prevent overlap with the label.
  /// Defaults to 0 pixels if not specified.
  final double? floatingLabelHeightCompensation;

  /// Additional padding from the left edge in logical pixels.
  ///
  /// Use this to fine-tune the content position from the left edge of the field.
  /// Positive values move content right, negative values move it left.
  /// Defaults to 0 pixels if not specified.
  final double? leftCompensation;

  /// Additional padding from the right edge in logical pixels.
  ///
  /// Use this to fine-tune the content position from the right edge of the field.
  /// Positive values move content left, negative values move it right.
  /// Defaults to 0 pixels if not specified.
  final double? rightCompensation;

  /// Additional top offset in logical pixels applied to the display content.
  ///
  /// Useful for small vertical adjustments when decorating with helper/error text
  /// or when using custom fonts/themes. Positive values move the content down,
  /// negative values move it up. Compensation may be required because helper/error
  /// area and floating label metrics differ between platforms and themes.
  /// Defaults to 0 if not specified.
  final double? topCompensation;

  const AnyFormField({
    super.key,
    required this.displayBuilder,
    required this.decoration,
    this.minHeight,
    this.maxHeight,
    this.displayPadding = const EdgeInsets.fromLTRB(5, 10, 5, 5),
    this.controller,
    this.onChanged,
    this.onTap,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.herlperHeightCompensation,
    this.errorHeightCompensation,
    this.leftCompensation,
    this.rightCompensation,
    this.floatingLabelHeightCompensation,
    this.topCompensation,
  });

  @override
  State<AnyFormField<T>> createState() => _AnyFormFieldState<T>();
}

class _AnyFormFieldState<T> extends State<AnyFormField<T>> {
  late final AnyValueController<T> _controller;
  late final bool _isExternalController;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? AnyValueController(widget.initialValue);
  }

  @override
  void dispose() {
    if (!_isExternalController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: _controller.value,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (field) {
        return AnyField<T>(
          displayBuilder: widget.displayBuilder,
          controller: _controller,
          decoration: widget.decoration.copyWith(errorText: field.errorText),
          displayPadding: widget.displayPadding,
          maxHeight: widget.maxHeight,
          minHeight: widget.minHeight,
          onChanged: (value) {
            field.didChange(value);
          },
          onTap: widget.onTap,
          herlperHeightCompensation: widget.herlperHeightCompensation,
          errorHeightCompensation: widget.errorHeightCompensation,
          rightCompensation: widget.rightCompensation,
          leftCompensation: widget.leftCompensation,
          floatingLabelHeightCompensation:
              widget.floatingLabelHeightCompensation,
          topCompensation: widget.topCompensation,
        );
      },
    );
  }
}
