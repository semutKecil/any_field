/// any_field
///
/// A small Flutter package that provides AnyField (a flexible, read-only
/// input-looking widget for rendering arbitrary content) and utilities like
/// AnyValueController and AnyFormField. Use this package to build picker-style
/// fields that keep TextField chrome while rendering custom widgets inside.
///
/// Example:
/// ```dart
/// import 'package:any_field/any_field.dart';
///
/// final controller = AnyValueController<DateTime?>(null);
/// AnyField<DateTime?>(
///   displayBuilder: (c, v) => Text(v?.toIso8601String() ?? 'Pick a date'),
///   controller: controller,
///   onTap: (current) async {
///     final picked = await showDatePicker(...);
///     if (picked != null) controller.value = picked;
///   },
/// );
/// ```
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A flexible input field widget that can display arbitrary content of type [T].
///
/// AnyField provides a customizable input-like widget that maintains the look and feel
/// of a TextField while allowing any content to be displayed within it.
class AnyField<T> extends StatefulWidget {
  /// Creates an [AnyField].
  ///
  /// Parameters:
  /// - [displayBuilder]: builder that renders the current value.
  /// - [decoration]: input decoration (label, prefix/suffix, border, etc.).
  /// - [minHeight]/[maxHeight]: size constraints for the display area.
  /// - [displayPadding]: padding applied around the displayed content.
  /// - [controller]: optional [AnyValueController] that holds the value.
  /// - [onChanged]: called when controller value changes.
  /// - [onTap]: synchronous or asynchronous handler invoked on tap; handler
  ///   should update the controller (return value is ignored).
  const AnyField({
    super.key,
    required this.displayBuilder,
    this.decoration = const InputDecoration(),
    this.minHeight,
    this.maxHeight,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  /// Function that builds the widget to display the current value.
  ///
  /// Called whenever the field needs to render its content. Receives the current
  /// build context and value of type [T].
  final Widget Function(BuildContext context, T value) displayBuilder;

  /// Decoration to customize the appearance of the field.
  ///
  /// Supports all standard [InputDecoration] properties like labels, hints,
  /// borders, and prefix/suffix widgets.
  final InputDecoration decoration;

  /// Minimum height of the field in logical pixels.
  ///
  /// If null, the height will be determined by measuring the content.
  final double? minHeight;

  /// Maximum height the field can expand to in logical pixels.
  ///
  /// Content that would cause the field to exceed this height will scroll.
  final double? maxHeight;

  /// Controller that manages the field's value.
  ///
  /// Use this to read/write the current value and listen for changes.
  final AnyValueController<T>? controller;

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
  final FutureOr<void> Function(T? value)? onTap;

  @override
  State<AnyField<T>> createState() => _AnyFieldState<T>();
}

class _AnyFieldState<T> extends State<AnyField<T>> {
  late final AnyValueController<T> _controller;
  late final bool _isExternalController;
  late final _AnyCubit<T?> _fieldValue;
  final FocusNode _focusNode = FocusNode();
  final _AnyCubit<bool> _hasFocus = _AnyCubit(false);

  @override
  void initState() {
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? AnyValueController.empty();
    _fieldValue = _AnyCubit(_controller.value);
    _controller.addListener(onValueChange);
    super.initState();
  }

  bool isValueEmpty(T? value) {
    // var value = _controller.value;
    if (value != null) {
      if (value is List && value.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  void onValueChange() {
    widget.onChanged?.call(_controller.value);
    _fieldValue.update(_controller.value);
  }

  @override
  void dispose() {
    _controller.removeListener(onValueChange);
    if (!_isExternalController) {
      _controller.dispose();
    }
    _hasFocus.close();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> onFocusTap() async {
    await widget.onTap?.call(_controller.value);
    onValueChange();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: _focusNode,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (_focusNode.hasFocus) {
              onFocusTap();
            }
            return null;
          },
        ),
      },
      onFocusChange: (value) => _hasFocus.update(value),
      child: GestureDetector(
        onTap: onFocusTap,
        child: BlocBuilder<_AnyCubit<T?>, T?>(
          bloc: _fieldValue,
          buildWhen: (previous, current) =>
              isValueEmpty(previous) || isValueEmpty(current),
          builder: (context, state) {
            return BlocBuilder<_AnyCubit<bool>, bool>(
              bloc: _hasFocus,
              builder: (context, focus) {
                return InputDecorator(
                  isEmpty: isValueEmpty(state),
                  isFocused: focus,
                  decoration: widget.decoration,
                  child: Container(
                    height: widget.minHeight == null && widget.maxHeight == null
                        ? 25
                        : null,
                    constraints:
                        widget.minHeight != null && widget.maxHeight != null
                        ? BoxConstraints(
                            minHeight: widget.minHeight!,
                            maxHeight: widget.maxHeight!,
                          )
                        : (widget.minHeight != null
                              ? BoxConstraints(
                                  minHeight: widget.minHeight!,
                                  maxHeight: widget.minHeight!,
                                )
                              : widget.maxHeight != null
                              ? BoxConstraints(maxHeight: widget.maxHeight!)
                              : null),
                    child: isValueEmpty(state)
                        ? SizedBox.shrink()
                        : SingleChildScrollView(
                            child: BlocBuilder<_AnyCubit<T?>, T?>(
                              bloc: _fieldValue,
                              builder: (context, data) {
                                return Align(
                                  alignment: AlignmentGeometry.topLeft,
                                  child: widget.displayBuilder(
                                    context,
                                    data as T,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Controller for managing values in [AnyField] widgets.
class AnyValueController<T> extends ChangeNotifier {
  /// The current value managed by this controller.
  T? _value;

  /// Optional custom comparison used to decide whether to notify listeners.
  ///
  /// Called with (previous, current) and should return true if listeners
  /// must be notified.
  final bool Function(T previous, T current)? shouldNotify;

  /// Constructs a controller initialized with [value].
  AnyValueController(this._value, {this.shouldNotify});

  /// Convenience constructor that creates an empty (null) controller.
  factory AnyValueController.empty() {
    return AnyValueController(null);
  }

  /// Current value held by the controller.
  ///
  /// Use the setter to update the value. When setting, the controller will:
  /// - Use [shouldNotify] if provided to determine whether listeners should be notified,
  /// - Otherwise compare with `!=` and notify on change.
  T? get value => _value;

  /// Updates the controller's value and notifies listeners if required.
  ///
  /// Setting this property updates the internal value and notifies registered
  /// listeners according to the logic described above.
  set value(T? newValue) {
    final shouldUpdate =
        (_value == null && newValue != null) ||
        (_value != null && newValue == null) ||
        (shouldNotify?.call(_value as T, newValue as T) ?? _value != newValue);
    if (shouldUpdate) {
      _value = newValue;
      notifyListeners();
    }
  }
}

class _AnyCubit<T> extends Cubit<T> {
  _AnyCubit(super.data);
  void update(T data) {
    emit(data);
  }
}
