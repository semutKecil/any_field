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
  /// - Compensation params: use to fine tune layout on different platforms.
  const AnyField({
    super.key,
    required this.displayBuilder,
    this.decoration = const InputDecoration(),
    this.minHeight,
    this.maxHeight,
    this.displayPadding = const EdgeInsets.fromLTRB(5, 10, 5, 5),
    this.controller,
    this.onChanged,
    this.onTap,
    this.herlperHeightCompensation,
    this.errorHeightCompensation,
    this.floatingLabelHeightCompensation,
    this.leftCompensation,
    this.rightCompensation,
    this.topCompensation,
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

  /// Padding applied around the display content within the field.
  final EdgeInsets displayPadding;

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

  @override
  State<AnyField<T>> createState() => _AnyFieldState<T>();
}

class _AnyFieldState<T> extends State<AnyField<T>> {
  late final AnyValueController<T> _controller;
  late final bool _isExternalController;
  late final _AnyCubit<T?> _fieldValue;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _suffixKey = GlobalKey();
  final GlobalKey _prefixKey = GlobalKey();

  final _AnyCubit<bool> _initialized = _AnyCubit(false);
  final _AnyCubit<double> _contentHeight = _AnyCubit(0);
  final TextEditingController _textController = TextEditingController();

  double _minusPrefix = 0;
  double _minusSuffix = 0;
  double _minHeight = 0;

  @override
  void initState() {
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? AnyValueController.empty();
    _fieldValue = _AnyCubit(_controller.value);
    if (_controller.value != null) {
      _textController.text = " ";
    } else {
      _textController.text = "";
    }

    _controller.addListener(onValueChange);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_initialized.state) {
        final RenderBox? renderBoxSuffix =
            _suffixKey.currentContext?.findRenderObject() as RenderBox?;
        _minusSuffix = renderBoxSuffix?.size.width ?? 0;

        final RenderBox? renderBoxPrefix =
            _prefixKey.currentContext?.findRenderObject() as RenderBox?;
        _minusPrefix = renderBoxPrefix?.size.width ?? 0;

        if (widget.minHeight != null) {
          _minHeight = widget.minHeight!;
        } else {
          final RenderBox renderBoxContent =
              _contentKey.currentContext!.findRenderObject() as RenderBox;
          _minHeight = initializeWidth(
            renderBoxContent.size.height,
            widget.decoration,
          );
        }
        _contentHeight.update(_minHeight);
        _initialized.update(true);
      }
    });
  }

  bool isValueEmpty() {
    if (_controller.value != null) {
      var value = _controller.value;
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
    if (isValueEmpty()) {
      _textController.text = "";
    } else {
      _textController.text = " ";
    }
    widget.onChanged?.call(_controller.value);
    _fieldValue.update(_controller.value);
  }

  @override
  void dispose() {
    _controller.removeListener(onValueChange);
    if (!_isExternalController) {
      _controller.dispose();
    }
    _textController.dispose();
    _initialized.close();
    _contentHeight.close();
    _focusNode.dispose();
    super.dispose();
  }

  InputDecoration decorationUpdate() {
    var decoration = widget.decoration;
    if (decoration.prefix != null) {
      decoration = decoration.copyWith(
        prefix: Container(key: _prefixKey, child: decoration.prefix),
      );
    }

    if (decoration.prefixIcon != null) {
      decoration = decoration.copyWith(
        prefix: null,
        prefixIcon: Container(key: _prefixKey, child: decoration.prefixIcon),
      );
    }

    if (decoration.suffix != null) {
      decoration = decoration.copyWith(
        suffix: Container(key: _suffixKey, child: decoration.suffix),
      );
    }

    if (decoration.suffixIcon != null) {
      decoration = decoration.copyWith(
        suffix: null,
        suffixIcon: Container(key: _suffixKey, child: decoration.suffixIcon),
      );
    }
    return decoration;
  }

  double initializeWidth(double height, InputDecoration decoration) {
    var nh = height;
    if (decoration.error != null || decoration.errorText != null) {
      nh -= widget.errorHeightCompensation ?? 20;
    } else if (decoration.helper != null || decoration.helperText != null) {
      nh -= widget.herlperHeightCompensation ?? 20;
    }
    return nh;
  }

  double heightCalculation(double height, InputDecoration decoration) {
    var nh = height;
    if (decoration.error != null || decoration.errorText != null) {
      nh += widget.errorHeightCompensation ?? 20;
    } else if (decoration.helper != null || decoration.helperText != null) {
      nh += widget.herlperHeightCompensation ?? 20;
    }

    return nh;
  }

  Future<void> onFocusTap() async {
    if (isValueEmpty()) {
      _textController.text = " ";
    }
    await widget.onTap?.call(_controller.value);
    onValueChange();
  }

  @override
  Widget build(BuildContext context) {
    var decoration = decorationUpdate();
    return BlocBuilder<_AnyCubit<bool>, bool>(
      bloc: _initialized,
      builder: (context, initialized) {
        if (!initialized) {
          return SizedBox(
            key: _contentKey,
            child: TextField(decoration: decoration, readOnly: true),
          );
        }
        return FocusableActionDetector(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  BlocBuilder<_AnyCubit<double>, double>(
                    bloc: _contentHeight,
                    builder: (context, height) {
                      return SizedBox(
                        // key: _contentKey,
                        height: heightCalculation(height, decoration),
                        child: Padding(
                          padding:
                              widget.floatingLabelHeightCompensation == null
                              ? EdgeInsetsGeometry.zero
                              : EdgeInsets.only(
                                  top: widget.floatingLabelHeightCompensation!,
                                ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            minLines: null,
                            maxLines: null,
                            decoration: decoration,
                            readOnly: true,
                            expands: true,
                            onTap: () {
                              onFocusTap();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top:
                        (widget.topCompensation ?? 0) +
                        (widget.floatingLabelHeightCompensation ?? 0),
                    left: _minusPrefix + (widget.leftCompensation ?? 0),
                    child: BlocBuilder<_AnyCubit<double>, double>(
                      bloc: _contentHeight,
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, height) {
                        return GestureDetector(
                          onTap: () {
                            widget.onTap?.call(_controller.value);
                          },
                          child: Container(
                            // color: Colors.amber,
                            width:
                                constraints.maxWidth -
                                (_minusPrefix +
                                    _minusSuffix +
                                    (widget.leftCompensation ?? 0) +
                                    (widget.rightCompensation ?? 0)),
                            // height: height,
                            constraints: BoxConstraints(
                              maxHeight:
                                  widget.maxHeight != null &&
                                      height >= widget.maxHeight!
                                  ? (height -
                                        (widget.topCompensation ?? 0) -
                                        (widget.floatingLabelHeightCompensation ??
                                            0) -
                                        (widget.herlperHeightCompensation ??
                                            0) -
                                        (widget.errorHeightCompensation ?? 0))
                                  : height,
                            ),
                            child: Padding(
                              padding: widget.displayPadding,
                              child:
                                  NotificationListener<
                                    ScrollMetricsNotification
                                  >(
                                    onNotification: (notification) {
                                      if (widget.maxHeight != null) {
                                        var more = notification
                                            .metrics
                                            .maxScrollExtent;
                                        var extra =
                                            (widget.topCompensation ?? 0) +
                                            (widget.displayPadding.top) +
                                            (widget.displayPadding.bottom);

                                        var nh =
                                            extra +
                                            more +
                                            notification
                                                .metrics
                                                .viewportDimension;

                                        if (nh > widget.maxHeight!) {
                                          _contentHeight.update(
                                            widget.maxHeight!,
                                          );
                                        } else if (nh < _minHeight) {
                                          _contentHeight.update(_minHeight);
                                        } else {
                                          _contentHeight.update(nh);
                                        }
                                      }
                                      return false;
                                    },
                                    child: SingleChildScrollView(
                                      child: BlocBuilder<_AnyCubit<T?>, T?>(
                                        bloc: _fieldValue,
                                        builder: (context, data) {
                                          if (data == null) {
                                            return SizedBox.shrink();
                                          }
                                          return Align(
                                            alignment:
                                                AlignmentGeometry.topLeft,
                                            child: Container(
                                              // color: Colors.blue,
                                              child: widget.displayBuilder(
                                                context,
                                                data as T,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
