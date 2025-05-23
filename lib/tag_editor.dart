import 'dart:async';
import 'dart:math';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:super_tag_editor/suggestions_box_controller.dart';
import 'package:super_tag_editor/utils/direction_helper.dart';
import 'package:super_tag_editor/widgets/validation_suggestion_item.dart';

import './tag_editor_layout_delegate.dart';
import './tag_layout.dart';

typedef SuggestionBuilder<T> = Widget Function(
    BuildContext context,
    TagsEditorState<T> state,
    T data,
    int index,
    int lenght,
    bool highlight,
    String? suggestionValid);
typedef InputSuggestions<T> = FutureOr<List<T>> Function(String query);
typedef SearchSuggestions<T> = FutureOr<List<T>> Function();
typedef OnDeleteTagAction = Function();
typedef OnFocusTagAction = Function(bool focused);
typedef OnSelectOptionAction<T> = Function(T data);
typedef OnHandleKeyEventAction = Function(KeyEvent event);
typedef OnFocusTextInputFieldCallback = Function();

/// A [Widget] for editing tag similar to Google's Gmail
/// email address input widget in the iOS app.
class TagEditor<T> extends StatefulWidget {
  const TagEditor(
      {required this.length,
      this.minTextFieldWidth = 160.0,
      this.tagSpacing = 4.0,
      required this.tagBuilder,
      required this.onTagChanged,
      required this.suggestionBuilder,
      required this.findSuggestions,
      Key? key,
      this.focusNode,
      this.focusNodeKeyboard,
      this.onHandleKeyEventAction,
      this.hasAddButton = false,
      this.delimiters = const [],
      this.icon,
      this.enabled = true,
      this.controller,
      this.textStyle,
      this.inputDecoration = const InputDecoration(),
      this.keyboardType,
      this.textInputAction,
      this.textCapitalization = TextCapitalization.none,
      this.textAlign = TextAlign.start,
      this.textDirection,
      this.readOnly = false,
      this.autofocus = false,
      this.autocorrect = false,
      this.enableSuggestions = true,
      this.maxLines = 1,
      this.resetTextOnSubmitted = false,
      this.onSubmitted,
      this.inputFormatters,
      this.keyboardAppearance,
      this.suggestionsBoxMaxHeight,
      this.suggestionsBoxElevation,
      this.suggestionsBoxBackgroundColor,
      this.suggestionsBoxRadius,
      this.iconSuggestionBox,
      this.searchAllSuggestions,
      this.debounceDuration,
      this.activateSuggestionBox = true,
      this.cursorColor,
      this.backgroundColor,
      this.focusedBorderColor,
      this.enableBorderColor,
      this.borderRadius,
      this.borderSize,
      this.padding,
      this.suggestionPadding,
      this.suggestionBoxWidth,
      this.suggestionMargin,
      this.suggestionItemHeight,
      this.onDeleteTagAction,
      this.onFocusTagAction,
      this.onTapOutside,
      this.itemHighlightColor,
      this.useDefaultHighlight = true,
      this.enableFocusAfterEnter = true,
      this.enableBorder = false,
      this.autoScrollToInput = true,
      this.autoHideTextInputField = false,
      this.isLoadMoreOnlyOnce = false,
      this.isLoadMoreReplaceAllOld = true,
      this.onFocusTextInput,
      this.onSelectOptionAction,
      this.loadMoreSuggestions})
      : assert(
            !autoHideTextInputField ||
                (!hasAddButton &&
                    (inputDecoration ==
                        const InputDecoration(border: InputBorder.none))),
            'The `autoHideTextInputField` feature is only available when `hasAddButton is false` and `inputDecoration is InputDecoration(border: InputBorder.none)`'),
        super(key: key);

  /// The number of tags currently shown.
  final int length;

  /// The minimum width that the `TextField` should take
  final double minTextFieldWidth;

  /// The spacing between each tag
  final double tagSpacing;

  /// Builder for building the tags, this usually use Flutter's Material `Chip`.
  final Widget Function(BuildContext, int) tagBuilder;

  /// Show the add button to the right.
  final bool hasAddButton;

  /// The icon for the add button enabled with `hasAddButton`.
  final IconData? icon;

  /// Callback for when the tag changed. Use this to get the new tag and add
  /// it to the state.
  final ValueChanged<String> onTagChanged;

  /// When the string value in this `delimiters` is found, a new tag will be
  /// created and `onTagChanged` is called.
  final List<String> delimiters;

  /// Reset the TextField when `onSubmitted` is called
  /// this is default to `false` because when the form is submitted
  /// usually the outstanding value is just used, but this option is here
  /// in case you want to reset it for any reasons (like converting the
  /// outstanding value to tag).
  final bool resetTextOnSubmitted;

  /// Called when the user are done editing the text in the [TextField]
  /// Use this to get the outstanding text that aren't converted to tag yet
  /// If no text is entered when this is called an empty string will be passed.
  final ValueChanged<String>? onSubmitted;

  /// Focus node for checking if the [TextField] is focused.
  final FocusNode? focusNode;

  /// Focus node for KeyboardRawListener.
  final FocusNode? focusNodeKeyboard;
  final OnHandleKeyEventAction? onHandleKeyEventAction;

  final OnDeleteTagAction? onDeleteTagAction;
  final OnFocusTagAction? onFocusTagAction;

  /// Enable border layout tab
  final bool enableBorder;

  /// Enable automatic scrolling to the currently focused input
  final bool autoScrollToInput;

  /// [TextField]'s properties.
  ///
  /// Please refer to [TextField] documentation.
  final TextEditingController? controller;
  final bool enabled;
  final TextStyle? textStyle;
  final InputDecoration inputDecoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Brightness? keyboardAppearance;
  final Color? cursorColor;
  final Color? backgroundColor;
  final Color? focusedBorderColor;
  final Color? enableBorderColor;
  final double? borderRadius;
  final double? borderSize;
  final EdgeInsets? padding;
  final bool enableFocusAfterEnter;
  final TapRegionCallback? onTapOutside;
  final OnFocusTextInputFieldCallback? onFocusTextInput;

  /// Enable automatic hide [TextField] when the text field overflows, the text is empty and focus is lost.
  final bool autoHideTextInputField;

  /// [SuggestionBox]'s properties.
  final double? suggestionsBoxMaxHeight;
  final double? suggestionsBoxElevation;
  final SuggestionBuilder<T> suggestionBuilder;
  final InputSuggestions<T> findSuggestions;
  final SearchSuggestions<T>? searchAllSuggestions;
  final OnSelectOptionAction<T>? onSelectOptionAction;
  final InputSuggestions<T>? loadMoreSuggestions;
  final Color? suggestionsBoxBackgroundColor;
  final Color? itemHighlightColor;
  final double? suggestionsBoxRadius;
  final Widget? iconSuggestionBox;
  final Duration? debounceDuration;
  final bool activateSuggestionBox;
  final EdgeInsets? suggestionMargin;
  final EdgeInsets? suggestionPadding;
  final bool useDefaultHighlight;
  final double? suggestionBoxWidth;
  final double? suggestionItemHeight;
  final bool isLoadMoreOnlyOnce;
  final bool isLoadMoreReplaceAllOld;

  @override
  TagsEditorState<T> createState() => TagsEditorState<T>();
}

class TagsEditorState<T> extends State<TagEditor<T>> {
  static const double defaultItemHeight = 50.0;

  /// A controller to keep value of the [TextField].
  late TextEditingController _textFieldController;
  late TextDirection _textDirection;

  /// A state variable for checking if new text is enter.
  var _previousText = '';

  /// A state for checking if the [TextFiled] has focus.
  var _isFocused = false;

  /// Focus node for checking if the [TextField] is focused.
  late FocusNode _focusNode;

  StreamController<List<T>?>? _suggestionsStreamController;
  SuggestionsBoxController? _suggestionsBoxController;
  final _layerLink = LayerLink();
  List<T>? _suggestions;
  int _searchId = 0;
  int _countBackspacePressed = 0;
  bool _isLoadingMore = false;
  Debouncer<String>? _deBouncer;
  final ValueNotifier<int> _highlightedOptionIndex = ValueNotifier<int>(0);
  final ValueNotifier<String?> _validationSuggestionItemNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> _loadingMoreStatus = ValueNotifier<bool>(false);
  final ScrollController _scrollController = ScrollController();

  RenderBox? get renderBox => context.findRenderObject() as RenderBox?;

  @override
  void initState() {
    super.initState();
    _textFieldController = (widget.controller ?? TextEditingController());
    _textDirection = widget.textDirection ?? TextDirection.ltr;

    _focusNode = (widget.focusNode ?? FocusNode())
      ..addListener(_onFocusChanged);

    if (widget.focusNodeKeyboard != null) {
      widget.focusNodeKeyboard!.addListener(_onFocusKeyboardChanged);
    }

    if (widget.activateSuggestionBox) _initializeSuggestionBox();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNodeKeyboard != null) {
      widget.focusNodeKeyboard!.removeListener(_onFocusKeyboardChanged);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _suggestionsStreamController?.close();
    _suggestionsBoxController?.close();
    _highlightedOptionIndex.dispose();
    _validationSuggestionItemNotifier.dispose();
    _loadingMoreStatus.dispose();
    _deBouncer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateHighlight(int newIndex) {
    _highlightedOptionIndex.value =
        _suggestions?.isNotEmpty == true ? newIndex % _suggestions!.length : 0;
  }

  void _highlightPreviousOption() {
    if (_suggestions?.isNotEmpty != true || _highlightedOptionIndex.value <= 0) {
      return;
    }

    final newIndex =
        (_highlightedOptionIndex.value - 1).clamp(0, _suggestions!.length - 1);
    _updateHighlight(newIndex);
    _scrollToCenterHighlightedItem();
  }

  void _highlightNextOption() {
    if (_suggestions?.isNotEmpty != true) return;

    if (_highlightedOptionIndex.value >= _suggestions!.length - 1) return;

    final newIndex =
        (_highlightedOptionIndex.value + 1).clamp(0, _suggestions!.length - 1);
    _updateHighlight(newIndex);

    debugPrint(
        'TagsEditorState::_highlightNextOption:newIndex = $newIndex | _suggestions = ${_suggestions?.length} | _isLoadingMore = $_isLoadingMore');

    _scrollToCenterHighlightedItem();

    if (widget.loadMoreSuggestions != null &&
        _highlightedOptionIndex.value == _suggestions!.length - 1 &&
        !_isLoadingMore) {
      _loadMoreSuggestion();
    }
  }

  void _scrollToCenterHighlightedItem() {
    debugPrint(
        'TagsEditorState::_scrollToCenterHighlightedItem:_highlightedOptionIndex = ${_highlightedOptionIndex.value}');
    final itemHeight = widget.suggestionItemHeight ?? defaultItemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final centerOffset = (viewportHeight - itemHeight) / 2;

    double scrollOffset =
        (_highlightedOptionIndex.value * itemHeight) - centerOffset;

    scrollOffset = scrollOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _selectOption() {
    final currentHighlightIndex = _highlightedOptionIndex.value;
    if (_suggestions?.isNotEmpty == true &&
        currentHighlightIndex >= 0 &&
        currentHighlightIndex < _suggestions!.length) {
      final optionSelected = _suggestions![currentHighlightIndex];
      widget.onSelectOptionAction?.call(optionSelected);
      resetTextField();
      closeSuggestionBox();
    }
  }

  void _updateValidationSuggestionItem(String? value) {
    _validationSuggestionItemNotifier.value = value;
  }

  void _initializeSuggestionBox() {
    _deBouncer = Debouncer<String>(
        widget.debounceDuration ?? const Duration(milliseconds: 300),
        initialValue: '');

    _deBouncer?.values.listen(_onSearchChanged);

    _suggestionsBoxController = SuggestionsBoxController(context);
    _suggestionsStreamController = StreamController<List<T>?>.broadcast();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _createOverlayEntry();
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (widget.focusNodeKeyboard != null) {
        widget.onFocusTagAction?.call(false);
        _countBackspacePressed = 0;
      }
      if (widget.autoScrollToInput) {
        _scrollToVisible();
      }
      _suggestionsBoxController?.open();
    } else {
      _suggestionsBoxController?.close();
    }

    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _onFocusKeyboardChanged() {
    if (widget.focusNodeKeyboard?.hasFocus == true) {
      widget.onFocusTagAction?.call(true);
      _countBackspacePressed = 1;
    } else {
      widget.onFocusTagAction?.call(false);
      _countBackspacePressed = 0;
    }
  }

  void _createOverlayEntry() {
    _suggestionsBoxController?.overlayEntry = OverlayEntry(
      builder: (context) {
        if (renderBox != null) {
          final size = renderBox!.size;
          final renderBoxOffset = renderBox!.localToGlobal(Offset.zero);
          final topAvailableSpace = renderBoxOffset.dy + size.height - 20;
          final mq = MediaQuery.of(context);
          final bottomAvailableSpace = mq.size.height -
              mq.viewInsets.bottom -
              renderBoxOffset.dy -
              size.height;

          final maxAvailableSpace =
              max(topAvailableSpace, bottomAvailableSpace) - 50;

          final suggestionBoxHeight = widget.suggestionsBoxMaxHeight != null
              ? min(maxAvailableSpace, widget.suggestionsBoxMaxHeight!)
              : maxAvailableSpace;

          final showTop = topAvailableSpace > bottomAvailableSpace;

          return StreamBuilder<List<T>?>(
            stream: _suggestionsStreamController?.stream,
            initialData: _suggestions,
            builder: (context, snapshot) {
              if (snapshot.data?.isNotEmpty == true) {
                Widget listViewWidget = ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  padding: widget.suggestionPadding ?? EdgeInsets.zero,
                  itemCount: widget.loadMoreSuggestions != null
                      ? snapshot.data!.length + 1
                      : snapshot.data!.length,
                  itemBuilder: (context, index) {
                    if (_suggestions?.isNotEmpty != true) {
                      return const SizedBox.shrink();
                    }

                    if (widget.loadMoreSuggestions != null &&
                        index == snapshot.data!.length) {
                      return ValueListenableBuilder(
                        valueListenable: _loadingMoreStatus,
                        builder: (_, value, __) {
                          if (value) {
                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(bottom: 12),
                              child: const SizedBox(
                                height: 24,
                                width: 24,
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    }

                    final item = _suggestions![index];
                    final highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    final suggestionValid =
                        ValidationSuggestionItem.of(context);

                    final itemWidget = widget.suggestionBuilder(
                      context,
                      this,
                      item,
                      index,
                      snapshot.data!.length,
                      highlight,
                      suggestionValid,
                    );

                    if (widget.useDefaultHighlight && highlight) {
                      return ColoredBox(
                        color: widget.itemHighlightColor ??
                            Theme.of(context).focusColor,
                        child: itemWidget,
                      );
                    } else {
                      return itemWidget;
                    }
                  },
                );

                if (widget.loadMoreSuggestions != null) {
                  listViewWidget = NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: listViewWidget,
                  );
                }

                final suggestionsListView = TextFieldTapRegion(
                  child: PointerInterceptor(
                    child: AutocompleteHighlightedOption(
                      highlightIndexNotifier: _highlightedOptionIndex,
                      child: ValidationSuggestionItem(
                        validationNotifier: _validationSuggestionItemNotifier,
                        child: Padding(
                          padding: widget.suggestionMargin ?? EdgeInsets.zero,
                          child: Material(
                            elevation: widget.suggestionsBoxElevation ?? 20,
                            borderRadius: BorderRadius.all(Radius.circular(
                                widget.suggestionsBoxRadius ?? 20)),
                            color: widget.suggestionsBoxBackgroundColor ??
                                Colors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  widget.suggestionsBoxRadius ?? 20)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.suggestionsBoxBackgroundColor ??
                                      Colors.white,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          widget.suggestionsBoxRadius ?? 0)),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: suggestionBoxHeight,
                                ),
                                child: listViewWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                final itemHeight =
                    widget.suggestionItemHeight ?? defaultItemHeight;
                final heightSuggestion = itemHeight * snapshot.data!.length;
                final offsetY = min(heightSuggestion, suggestionBoxHeight);
                final compositedTransformFollowerOffset = showTop && offsetY > bottomAvailableSpace
                    ? Offset(0, -1.0 * (offsetY + itemHeight))
                    : Offset.zero;

                return Positioned(
                  width: widget.suggestionBoxWidth ?? size.width,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: compositedTransformFollowerOffset,
                    child: suggestionsListView,
                  ),
                );
              }
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollEndNotification &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
        scrollInfo.metrics.axisDirection == AxisDirection.down &&
        !_isLoadingMore) {
      _loadMoreSuggestion();
    }
    return false;
  }

  Future<void> _loadMoreSuggestion() async {
    final currentSuggestionValue = _validationSuggestionItemNotifier.value;
    debugPrint(
        'TagsEditorState::_loadMoreSuggestion:currentSuggestionValue = $currentSuggestionValue');

    if (currentSuggestionValue == null) return;

    _isLoadingMore = true;
    _loadingMoreStatus.value = true;

    final results =
        await widget.loadMoreSuggestions?.call(currentSuggestionValue);
    debugPrint(
        'TagsEditorState::_loadMoreSuggestion:results = ${results?.length}');
    if (results?.isNotEmpty != true) {
      _isLoadingMore = widget.isLoadMoreOnlyOnce;
      _loadingMoreStatus.value = false;
      return;
    }

    if (!widget.isLoadMoreReplaceAllOld && _suggestions?.isNotEmpty == true) {
      final newSuggestions =
          results?.where((element) => !_suggestions!.contains(element)) ?? [];
      final newList = [..._suggestions!, ...newSuggestions];

      if (mounted) {
        setState(() => _suggestions = newList);
      }
    } else {
      if (mounted) {
        setState(() => _suggestions = results);
      }
    }

    _suggestionsStreamController?.add(_suggestions ?? []);
    _suggestionsBoxController?.open();

    _isLoadingMore = widget.isLoadMoreOnlyOnce;
    _loadingMoreStatus.value = false;
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTagChanged(String string) {
    if (string.isNotEmpty) {
      widget.onTagChanged(string);
      resetTextField();
    }
  }

  /// This function is still ugly, have to fix this later
  void _onTextFieldChange(String string) {
    if (string != _previousText) {
      _deBouncer?.value = string;
    }

    final previousText = _previousText;

    setState(() {
      _previousText = string;
    });

    if (string.isEmpty || widget.delimiters.isEmpty) {
      return;
    }

    // Do not allow the entry of the delimters, this does not account for when
    // the text is set with `TextEditingController` the behaviour of TextEditingContoller
    // should be controller by the developer themselves
    if (string.length == 1 && widget.delimiters.contains(string)) {
      resetTextField();
      return;
    }

    if (string.length > previousText.length) {
      // Add case
      final newChar = string[string.length - 1];
      if (widget.delimiters.contains(newChar)) {
        final targetString = string.substring(0, string.length - 1);
        if (targetString.isNotEmpty) {
          _onTagChanged(targetString);
        }
      }
    }
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    final results = await widget.findSuggestions(value);
    if (_searchId == localId && mounted) {
      setState(() => _suggestions = results);
    }
    _updateHighlight(0);
    _updateValidationSuggestionItem(value);
    _suggestionsStreamController?.add(_suggestions ?? []);
    _suggestionsBoxController?.open();
    _isLoadingMore = false;
    _scrollToTop();
  }

  void openSuggestionBox() async {
    if (widget.searchAllSuggestions != null) {
      final localId = ++_searchId;
      final results = await widget.searchAllSuggestions!();
      if (_searchId == localId && mounted) {
        setState(() => _suggestions = results);
      }
      _updateHighlight(0);
      _updateValidationSuggestionItem(null);
      _suggestionsStreamController?.add(_suggestions ?? []);
      _suggestionsBoxController?.open();
      _isLoadingMore = false;
      _scrollToTop();
    }
  }

  void closeSuggestionBox({bool isClearData = true}) {
    if (isClearData) {
      _suggestions = null;
      _suggestionsStreamController?.add([]);
    }
    _updateHighlight(0);
    _updateValidationSuggestionItem(null);
    _suggestionsBoxController?.close();
    _isLoadingMore = false;
  }

  void _scrollToVisible() {
    Future.delayed(const Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          final renderBox = context.findRenderObject() as RenderBox;
          await Scrollable.of(context).position.ensureVisible(renderBox);
        }
      });
    });
  }

  void _onSubmitted(String string) {
    if (_suggestions?.isNotEmpty == true &&
        _suggestionsBoxController?.isOpened == true) {
      _selectOption();
    } else {
      widget.onSubmitted?.call(string);
      if (widget.resetTextOnSubmitted) {
        resetTextField();
      }
    }
    if (widget.enableFocusAfterEnter) {
      _focusNode.requestFocus();
    }
  }

  void resetTextField() {
    _textFieldController.text = '';
    _previousText = '';
    _updateHighlight(0);
    _updateValidationSuggestionItem(null);
  }

  /// Shamelessly copied from [InputDecorator]
  Color _getDefaultIconColor(ThemeData themeData) {
    if (!widget.enabled) {
      return themeData.disabledColor;
    }

    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
    }
  }

  /// Shamelessly copied from [InputDecorator]
  Color _getActiveColor(ThemeData themeData) {
    if (_focusNode.hasFocus) {
      switch (themeData.brightness) {
        case Brightness.dark:
          return themeData.colorScheme.secondary;
        case Brightness.light:
          return themeData.primaryColor;
      }
    }
    return themeData.hintColor;
  }

  Color _getIconColor(ThemeData themeData) {
    final themeData = Theme.of(context);
    final activeColor = _getActiveColor(themeData);
    return _isFocused ? activeColor : _getDefaultIconColor(themeData);
  }

  void _onKeyboardBackspaceListener() async {
    if (_textFieldController.text.isEmpty && widget.length > 0) {
      _countBackspacePressed++;

      if (_countBackspacePressed == 1) {
        _focusNode.unfocus();
        widget.focusNodeKeyboard?.requestFocus();
      } else if (_countBackspacePressed >= 2) {
        widget.onDeleteTagAction?.call();
        if (widget.length > 1) {
          _countBackspacePressed = 1;
        } else {
          _countBackspacePressed = 0;
          widget.focusNodeKeyboard?.unfocus();
          _focusNode.requestFocus();
        }
      }
    } else {
      widget.focusNodeKeyboard?.unfocus();
      _focusNode.requestFocus();
    }
  }

  double _getTextWidth(String text, {TextStyle? textStyle}) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle, // Make optional to subtitle1
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  void _handleKeyboardEvent(KeyEvent event) {
    widget.onHandleKeyEventAction?.call(event);

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.backspace:
          _onKeyboardBackspaceListener();
          break;
        case LogicalKeyboardKey.arrowDown:
          _highlightNextOption();
          break;
        case LogicalKeyboardKey.arrowUp:
          _highlightPreviousOption();
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.hasAddButton && widget.icon == null
        ? widget.inputDecoration.copyWith(
            suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _onTagChanged(_textFieldController.text);
            },
            child: const Icon(Icons.add),
          ))
        : widget.inputDecoration;

    final borderSize =
        widget.borderSize ?? ((_isFocused || widget.enableBorder) ? 1 : 0.5);
    var borderColor = Colors.transparent;
    if (widget.enableBorder) {
      borderColor = widget.enableBorderColor ?? Colors.transparent;
    }
    if (_isFocused) {
      borderColor = widget.focusedBorderColor ?? Colors.transparent;
    }
    final borderRadius = widget.borderRadius ?? 0;

    //* TextField use titleMedium for default style
    final defaultTextFieldTextStyle = Theme.of(context).textTheme.titleMedium;
    final textStyle = widget.textStyle?.fontSize == null
        ? widget.textStyle
            ?.copyWith(fontSize: defaultTextFieldTextStyle?.fontSize)
        : widget.textStyle?.copyWith();

    final textInputField = TextField(
      style: textStyle,
      focusNode: _focusNode,
      enabled: widget.enabled,
      controller: _textFieldController,
      keyboardType: widget.keyboardType,
      keyboardAppearance: widget.keyboardAppearance,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      cursorColor: widget.cursorColor,
      autocorrect: widget.autocorrect,
      textAlign: widget.textAlign,
      textDirection: _textDirection,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      decoration: decoration,
      onChanged: (value) {
        _onTextFieldChange.call(value);
        if (value.isNotEmpty) {
          final directionByText = DirectionHelper.getDirectionByEndsText(value);
          if (directionByText != _textDirection) {
            setState(() {
              _textDirection = directionByText;
            });
          }
        }
      },
      onSubmitted: _onSubmitted,
      inputFormatters: widget.inputFormatters,
      onTapOutside: widget.onTapOutside,
    );

    final isHideTextField = widget.autoHideTextInputField
        ? !_isFocused && _previousText.isEmpty
        : false;

    Widget tagEditorArea = Container(
      padding: widget.padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: Border.all(width: borderSize, color: borderColor),
          color: widget.backgroundColor ?? Colors.transparent),
      child: TagLayout(
        delegate: TagEditorLayoutDelegate(
            length: widget.length,
            minTextFieldWidth: widget.minTextFieldWidth,
            spacing: widget.tagSpacing,
            textWidth: _getTextWidth(_previousText, textStyle: textStyle),
            isHideTextField: isHideTextField),
        children: [
          ...List<Widget>.generate(
            widget.length,
            (index) => LayoutId(
              id: TagEditorLayoutDelegate.getTagId(index),
              child: widget.tagBuilder(context, index),
            ),
          ),
          LayoutId(
              id: TagEditorLayoutDelegate.textFieldId,
              child: widget.focusNodeKeyboard != null
                  ? KeyboardListener(
                      focusNode: widget.focusNodeKeyboard!,
                      onKeyEvent: _handleKeyboardEvent,
                      child: textInputField,
                    )
                  : textInputField)
        ],
      ),
    );

    if (widget.autoHideTextInputField) {
      tagEditorArea = GestureDetector(
        onTap: () {
          if (!_isFocused) {
            widget.onFocusTextInput?.call();
            setState(() => _isFocused = true);
            _focusNode.requestFocus();
          }
        },
        child: tagEditorArea,
      );
    }

    Widget? itemChild;

    if (widget.icon == null && widget.iconSuggestionBox == null) {
      itemChild = tagEditorArea;
    } else {
      itemChild = Row(
        children: <Widget>[
          if (widget.hasAddButton)
            Container(
              width: 40,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: _getIconColor(Theme.of(context)),
                  size: 18.0,
                ),
                child: Icon(widget.icon),
              ),
            ),
          if (widget.iconSuggestionBox != null)
            Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: IconButton(
                    icon: widget.iconSuggestionBox!,
                    splashRadius: 20,
                    onPressed: () => openSuggestionBox())),
          Expanded(child: tagEditorArea),
        ],
      );
    }

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification val) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _suggestionsBoxController?.overlayEntry?.markNeedsBuild();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Column(
          children: <Widget>[
            itemChild,
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
