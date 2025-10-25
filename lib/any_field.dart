import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A flexible input field widget that can display arbitrary content of type [T].
///
/// AnyField provides a customizable input-like widget that maintains the look and feel
/// of a TextField while allowing any content to be displayed within it.
class AnyField<T> extends StatefulWidget {
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
  final EdgeInsets? displayPadding;

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
  ///
  final void Function(T? value)? onTap;

  /// Compensation height in logical pixels for helper text area.
  ///
  /// When helper text is present, this value is used to adjust the display
  /// content position to prevent overlap with the helper area.
  /// Defaults to 21 pixels if not specified.
  final double? herlperHeightCompensation;

  /// Compensation height in logical pixels for error text area.
  ///
  /// When error text is present, this value is used to adjust the display
  /// content position to prevent overlap with the error area.
  /// Defaults to 21 pixels if not specified.
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

  const AnyField({
    super.key,
    required this.displayBuilder,
    this.decoration = const InputDecoration(),
    this.minHeight,
    this.maxHeight,
    this.displayPadding,
    this.controller,
    this.onChanged,
    this.onTap,
    this.herlperHeightCompensation,
    this.errorHeightCompensation,
    this.leftCompensation,
    this.rightCompensation,
    this.floatingLabelHeightCompensation,
  });

  @override
  State<AnyField<T>> createState() => _AnyFieldState<T>();
}

class _AnyFieldState<T> extends State<AnyField<T>> {
  final GlobalKey _suffixKey = GlobalKey();
  final GlobalKey _prefixKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  final _AnyCubit<bool> _initialized = _AnyCubit(false);
  double _minusPrefix = 0;
  double _minusSuffix = 0;
  double _minHeight = 0;

  @override
  void dispose() {
    _initialized.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
        _minHeight = widget.minHeight ?? renderBoxContent.size.height;
      }

      _initialized.update(true);
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return BlocBuilder<_AnyCubit<bool>, bool>(
      bloc: _initialized,
      builder: (context, state) {
        if (!state) {
          return SizedBox(
            key: _contentKey,
            height: widget.minHeight,
            child: Padding(
              padding: widget.floatingLabelHeightCompensation == null
                  ? EdgeInsetsGeometry.zero
                  : EdgeInsets.only(
                      top: widget.floatingLabelHeightCompensation!,
                    ),
              child: TextField(
                decoration: decoration,
                expands: widget.minHeight != null,
                maxLines: widget.minHeight != null ? null : 1,
                readOnly: true,
                onChanged: (value) {},
              ),
            ),
          );
        } else {
          return _AnyFieldCore<T>(
            displayBuilder: widget.displayBuilder,
            decoration: decoration,
            minHeight: _minHeight,
            minusPrefix: _minusPrefix,
            minusSuffix: _minusSuffix,
            maxHeight: widget.maxHeight,
            displayPadding: widget.displayPadding,
            controller: widget.controller,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            errorHeightCompensation: widget.errorHeightCompensation ?? 21,
            herlperHeightCompensation: widget.herlperHeightCompensation ?? 21,
            leftCompensation: widget.leftCompensation ?? 0,
            rightCompensation: widget.rightCompensation ?? 0,
            floatingLabelHeightCompensation:
                widget.floatingLabelHeightCompensation ?? 0,
          );
        }
      },
    );
  }
}

class _AnyFieldCore<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T value) displayBuilder;
  final InputDecoration decoration;
  final double minHeight;
  final double minusPrefix;
  final double minusSuffix;
  final double? maxHeight;
  final AnyValueController<T>? controller;

  final ValueChanged<T?>? onChanged;
  final void Function(T? value)? onTap;
  final EdgeInsets? displayPadding;

  final double herlperHeightCompensation;
  final double errorHeightCompensation;

  final double leftCompensation;
  final double rightCompensation;
  final double floatingLabelHeightCompensation;
  const _AnyFieldCore({
    required this.displayBuilder,
    required this.decoration,
    required this.minHeight,
    required this.minusPrefix,
    required this.minusSuffix,
    this.maxHeight,
    this.displayPadding,
    this.controller,
    this.onChanged,
    this.onTap,
    required this.herlperHeightCompensation,
    required this.errorHeightCompensation,
    required this.leftCompensation,
    required this.rightCompensation,
    required this.floatingLabelHeightCompensation,
  });

  @override
  State<_AnyFieldCore<T>> createState() => _AnyFieldCoreState<T>();
}

class _AnyFieldCoreState<T> extends State<_AnyFieldCore<T>> {
  final _AnyCubit<double> _heightChange = _AnyCubit(0);
  final TextEditingController _textController = TextEditingController();
  late final _AnyCubit<T?> _value;
  final FocusNode _focusNode = FocusNode();
  late final AnyValueController<T> _controller;
  late final bool _isExternalController;

  @override
  void initState() {
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? AnyValueController.empty();
    _heightChange.update(widget.minHeight);
    _value = _AnyCubit(_controller.value);
    if (_controller._value != null) {
      _textController.text = " ";
    } else {
      _textController.text = "";
    }
    _controller.addListener(onControllerChange);
    super.initState();
  }

  void onControllerChange() {
    _value.update(_controller.value);
    widget.onChanged?.call(_controller.value);
    if (_controller._value != null) {
      _textController.text = " ";
    } else {
      _textController.text = "";
    }
  }

  @override
  void dispose() {
    _controller.removeListener(onControllerChange);
    if (!_isExternalController) {
      _controller.dispose();
    }
    _textController.dispose();
    _heightChange.close();
    _value.close();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return BlocBuilder<_AnyCubit<double>, double>(
          bloc: _heightChange,
          builder: (context, height) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                height: height,
                child: Stack(
                  children: [
                    FocusableActionDetector(
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.enter):
                            const ActivateIntent(),
                      },
                      actions: {
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (_) {
                            if (_focusNode.hasFocus) {
                              widget.onTap?.call(_controller.value);
                            }
                            return null;
                          },
                        ),
                      },
                      child: Padding(
                        padding: widget.floatingLabelHeightCompensation == 0
                            ? EdgeInsetsGeometry.zero
                            : EdgeInsets.only(
                                top: widget.floatingLabelHeightCompensation,
                              ),
                        child: TextField(
                          focusNode: _focusNode,
                          decoration: widget.decoration,
                          controller: _textController,
                          expands: true,
                          maxLines: null,
                          readOnly: true,
                          onTap: () {
                            widget.onTap?.call(_controller.value);
                          },
                        ),
                      ),
                    ),
                    _DisplayPosition(
                      hasError:
                          widget.decoration.error != null ||
                          widget.decoration.errorText != null,
                      hasHelper:
                          widget.decoration.helper != null ||
                          widget.decoration.helperText != null,
                      errorHeightCompensation: widget.errorHeightCompensation,
                      herlperHeightCompensation:
                          widget.herlperHeightCompensation,
                      rightCompensation: widget.rightCompensation,
                      leftCompensation: widget.leftCompensation,
                      left: widget.minusPrefix,
                      width:
                          constrains.maxWidth -
                          (widget.minusPrefix + widget.minusSuffix),
                      floatingLabelHeightCompensation:
                          widget.floatingLabelHeightCompensation,
                      child: GestureDetector(
                        onTap: () {
                          widget.onTap?.call(_controller.value);
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    _DisplayPosition(
                      hasError:
                          widget.decoration.error != null ||
                          widget.decoration.errorText != null,
                      hasHelper:
                          widget.decoration.helper != null ||
                          widget.decoration.helperText != null,
                      errorHeightCompensation: widget.errorHeightCompensation,
                      herlperHeightCompensation:
                          widget.herlperHeightCompensation,
                      rightCompensation: widget.rightCompensation,
                      leftCompensation: widget.leftCompensation,
                      left: widget.minusPrefix,
                      width:
                          constrains.maxWidth -
                          (widget.minusPrefix + widget.minusSuffix),

                      floatingLabelHeightCompensation:
                          widget.floatingLabelHeightCompensation,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: BlocBuilder<_AnyCubit<T?>, T?>(
                              bloc: _value,
                              builder: (context, state) {
                                if (state == null) {
                                  _heightChange.update(widget.minHeight);
                                  return SizedBox.shrink();
                                }

                                return _Display(
                                  displayBuilder: widget.displayBuilder,
                                  height: _heightChange.state,
                                  minHeight: widget.minHeight,
                                  state: state,
                                  displayPadding:
                                      widget.displayPadding ??
                                      EdgeInsets.only(
                                        top: 10,
                                        left: 5,
                                        right: 5,
                                        bottom: 5,
                                      ),
                                  maxHeight: widget.maxHeight,
                                  onTap: () {
                                    widget.onTap?.call(_controller.value);
                                  },
                                  heightChange: (newHeight) {
                                    _heightChange.update(newHeight);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Display<T> extends StatefulWidget {
  final T state;
  final Widget Function(BuildContext context, T value) displayBuilder;
  final GestureTapCallback? onTap;
  final EdgeInsets displayPadding;
  final double height;
  final double minHeight;
  final void Function(double height) heightChange;
  final double? maxHeight;
  const _Display({
    super.key,
    required this.state,
    this.onTap,
    this.displayPadding = EdgeInsets.zero,
    required this.minHeight,
    this.maxHeight,
    required this.displayBuilder,
    required this.height,
    required this.heightChange,
  });

  @override
  State<_Display<T>> createState() => _DisplayState<T>();
}

class _DisplayState<T> extends State<_Display<T>> {
  double _viewDimension = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: widget.displayPadding,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            if (widget.maxHeight != null) {
              var more = notification.metrics.maxScrollExtent;
              if (more > 0) {
                if ((widget.height + more) < widget.maxHeight!) {
                  widget.heightChange(widget.height + more);
                } else {
                  widget.heightChange(widget.maxHeight!);
                }
              } else if (_viewDimension > 0 &&
                  _viewDimension > notification.metrics.viewportDimension) {
                var min =
                    _viewDimension - notification.metrics.viewportDimension;
                if ((widget.height - min) < widget.minHeight) {
                  widget.heightChange(widget.minHeight);
                } else {
                  widget.heightChange(widget.height - min);
                }
              }
              _viewDimension = notification.metrics.viewportDimension;
            }

            return false;
          },
          child: SingleChildScrollView(
            child: Align(
              alignment: AlignmentGeometry.topLeft,
              child: widget.displayBuilder(context, widget.state),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayPosition extends StatelessWidget {
  final bool hasError;
  final bool hasHelper;
  final double left;
  final double width;
  final Widget child;
  final double herlperHeightCompensation;
  final double errorHeightCompensation;
  final double rightCompensation;
  final double leftCompensation;
  final double floatingLabelHeightCompensation;
  const _DisplayPosition({
    required this.left,
    required this.width,
    required this.child,
    required this.hasError,
    required this.hasHelper,
    required this.herlperHeightCompensation,
    required this.errorHeightCompensation,
    required this.rightCompensation,
    required this.leftCompensation,
    required this.floatingLabelHeightCompensation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left + leftCompensation,
      top: floatingLabelHeightCompensation,
      bottom: hasError
          ? errorHeightCompensation
          : hasHelper
          ? herlperHeightCompensation
          : 0,
      width: width - rightCompensation,
      child: child,
    );
  }
}

/// Controller for managing values in [AnyField] widgets.
class AnyValueController<T> extends ChangeNotifier {
  /// The current value managed by this controller.
  T? _value;

  /// Optional function to determine when listeners should be notified.
  ///
  /// Called with the previous and new value when [value] is set.
  /// Return true to notify listeners, false to skip notification.
  final bool Function(T previous, T current)? shouldNotify;

  /// Creates a controller with an optional initial [value] and [shouldNotify] callback.
  AnyValueController(this._value, {this.shouldNotify});

  /// Creates an empty controller with null value.
  factory AnyValueController.empty() {
    return AnyValueController(null);
  }

  T? get value => _value;

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
