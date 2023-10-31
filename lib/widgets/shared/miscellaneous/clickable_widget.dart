import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

class ClickableWidget extends StatelessWidget {
  const ClickableWidget({
    super.key,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.cursor,
    this.opaque = true,
    this.hitTestBehavior,
    this.child,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPressDown,
    this.onLongPressCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPressDown,
    this.onSecondaryLongPressCancel,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    this.onTertiaryLongPressDown,
    this.onTertiaryLongPressCancel,
    this.onTertiaryLongPress,
    this.onTertiaryLongPressStart,
    this.onTertiaryLongPressMoveUpdate,
    this.onTertiaryLongPressUp,
    this.onTertiaryLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.trackpadScrollCausesScale = false,
    this.trackpadScrollToScaleFactor = kDefaultTrackpadScrollToScaleFactor,
    this.supportedDevices,
  });

  /// Triggered when a mouse pointer has entered this widget.
  ///
  /// This callback is triggered when the pointer, with or without buttons
  /// pressed, has started to be contained by the region of this widget. More
  /// specifically, the callback is triggered by the following cases:
  ///
  ///  * This widget has appeared under a pointer.
  ///  * This widget has moved to under a pointer.
  ///  * A new pointer has been added to somewhere within this widget.
  ///  * An existing pointer has moved into this widget.
  ///
  /// This callback is not always matched by an [onExit]. If the [MouseRegion]
  /// is unmounted while being hovered by a pointer, the [onExit] of the widget
  /// callback will never called. For more details, see [onExit].
  ///
  /// {@template flutter.widgets.MouseRegion.onEnter.triggerTime}
  /// The time that this callback is triggered is always between frames: either
  /// during the post-frame callbacks, or during the callback of a pointer
  /// event.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [onExit], which is triggered when a mouse pointer exits the region.
  ///  * [MouseTrackerAnnotation.onEnter], which is how this callback is
  ///    internally implemented.
  final PointerEnterEventListener? onEnter;

  /// Triggered when a pointer moves into a position within this widget without
  /// buttons pressed.
  ///
  /// Usually this is only fired for pointers which report their location when
  /// not down (e.g. mouse pointers). Certain devices also fire this event on
  /// single taps in accessibility mode.
  ///
  /// This callback is not triggered by the movement of the widget.
  ///
  /// The time that this callback is triggered is during the callback of a
  /// pointer event, which is always between frames.
  ///
  /// See also:
  ///
  ///  * [Listener.onPointerHover], which does the same job. Prefer using
  ///    [Listener.onPointerHover], since hover events are similar to other regular
  ///    events.
  final PointerHoverEventListener? onHover;

  /// Triggered when a mouse pointer has exited this widget when the widget is
  /// still mounted.
  ///
  /// This callback is triggered when the pointer, with or without buttons
  /// pressed, has stopped being contained by the region of this widget, except
  /// when the exit is caused by the disappearance of this widget. More
  /// specifically, this callback is triggered by the following cases:
  ///
  ///  * A pointer that is hovering this widget has moved away.
  ///  * A pointer that is hovering this widget has been removed.
  ///  * This widget, which is being hovered by a pointer, has moved away.
  ///
  /// And is __not__ triggered by the following case:
  ///
  ///  * This widget, which is being hovered by a pointer, has disappeared.
  ///
  /// This means that a [MouseRegion.onExit] might not be matched by a
  /// [MouseRegion.onEnter].
  ///
  /// This restriction aims to prevent a common misuse: if [State.setState] is
  /// called during [MouseRegion.onExit] without checking whether the widget is
  /// still mounted, an exception will occur. This is because the callback is
  /// triggered during the post-frame phase, at which point the widget has been
  /// unmounted. Since [State.setState] is exclusive to widgets, the restriction
  /// is specific to [MouseRegion], and does not apply to its lower-level
  /// counterparts, [RenderMouseRegion] and [MouseTrackerAnnotation].
  ///
  /// There are a few ways to mitigate this restriction:
  ///
  ///  * If the hover state is completely contained within a widget that
  ///    unconditionally creates this [MouseRegion], then this will not be a
  ///    concern, since after the [MouseRegion] is unmounted the state is no
  ///    longer used.
  ///  * Otherwise, the outer widget very likely has access to the variable that
  ///    controls whether this [MouseRegion] is present. If so, call [onExit] at
  ///    the event that turns the condition from true to false.
  ///  * In cases where the solutions above won't work, you can always
  ///    override [State.dispose] and call [onExit], or create your own widget
  ///    using [RenderMouseRegion].
  ///
  /// {@tool dartpad}
  /// The following example shows a blue rectangular that turns yellow when
  /// hovered. Since the hover state is completely contained within a widget
  /// that unconditionally creates the `MouseRegion`, you can ignore the
  /// aforementioned restriction.
  ///
  /// ** See code in examples/api/lib/widgets/basic/mouse_region.on_exit.0.dart **
  /// {@end-tool}
  ///
  /// {@tool dartpad}
  /// The following example shows a widget that hides its content one second
  /// after being hovered, and also exposes the enter and exit callbacks.
  /// Because the widget conditionally creates the `MouseRegion`, and leaks the
  /// hover state, it needs to take the restriction into consideration. In this
  /// case, since it has access to the event that triggers the disappearance of
  /// the `MouseRegion`, it triggers the exit callback during that event
  /// as well.
  ///
  /// ** See code in examples/api/lib/widgets/basic/mouse_region.on_exit.1.dart **
  /// {@end-tool}
  ///
  /// {@macro flutter.widgets.MouseRegion.onEnter.triggerTime}
  ///
  /// See also:
  ///
  ///  * [onEnter], which is triggered when a mouse pointer enters the region.
  ///  * [RenderMouseRegion] and [MouseTrackerAnnotation.onExit], which are how
  ///    this callback is internally implemented, but without the restriction.
  final PointerExitEventListener? onExit;

  /// The mouse cursor for mouse pointers that are hovering over the region.
  ///
  /// When a mouse enters the region, its cursor will be changed to the [cursor].
  /// When the mouse leaves the region, the cursor will be decided by the region
  /// found at the new location.
  ///
  /// The [cursor] defaults to [MouseCursor.defer], deferring the choice of
  /// cursor to the next region behind it in hit-test order.
  final MouseCursor? cursor;

  /// Whether this widget should prevent other [MouseRegion]s visually behind it
  /// from detecting the pointer.
  ///
  /// This changes the list of regions that a pointer hovers, thus affecting how
  /// their [onHover], [onEnter], [onExit], and [cursor] behave.
  ///
  /// If [opaque] is true, this widget will absorb the mouse pointer and
  /// prevent this widget's siblings (or any other widgets that are not
  /// ancestors or descendants of this widget) from detecting the mouse
  /// pointer even when the pointer is within their areas.
  ///
  /// If [opaque] is false, this object will not affect how [MouseRegion]s
  /// behind it behave, which will detect the mouse pointer as long as the
  /// pointer is within their areas.
  ///
  /// This defaults to true.
  final bool opaque;

  /// How to behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.opaque] if null.
  final HitTestBehavior? hitTestBehavior;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// A pointer that might cause a tap with a primary button has contacted the
  /// screen at a particular location.
  ///
  /// This is called after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [onTapUp] will be called,
  /// otherwise [onTapCancel] will be called.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapDownCallback? onTapDown;

  /// A pointer that will trigger a tap with a primary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers immediately before [onTap] in the case of the tap gesture
  /// winning. If the tap gesture did not win, [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapUpCallback? onTapUp;

  /// A tap with a primary button has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onTapUp], which is called at the same time but includes details
  ///    regarding the pointer position.
  final GestureTapCallback? onTap;

  /// The pointer that previously triggered [onTapDown] will not end up causing
  /// a tap.
  ///
  /// This is called after [onTapDown], and instead of [onTapUp] and [onTap], if
  /// the tap gesture did not win.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapCancelCallback? onTapCancel;

  /// A tap with a secondary button has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [onSecondaryTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [onSecondaryTapUp], which is called at the same time but includes details
  ///    regarding the pointer position.
  final GestureTapCallback? onSecondaryTap;

  /// A pointer that might cause a tap with a secondary button has contacted the
  /// screen at a particular location.
  ///
  /// This is called after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [onSecondaryTapUp] will be
  /// called, otherwise [onSecondaryTapCancel] will be called.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapDownCallback? onSecondaryTapDown;

  /// A pointer that will trigger a tap with a secondary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers in the case of the tap gesture winning. If the tap gesture
  /// did not win, [onSecondaryTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [onSecondaryTap], a handler triggered right after this one that doesn't
  ///    pass any details about the tap.
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapUpCallback? onSecondaryTapUp;

  /// The pointer that previously triggered [onSecondaryTapDown] will not end up
  /// causing a tap.
  ///
  /// This is called after [onSecondaryTapDown], and instead of
  /// [onSecondaryTapUp], if the tap gesture did not win.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapCancelCallback? onSecondaryTapCancel;

  /// A pointer that might cause a tap with a tertiary button has contacted the
  /// screen at a particular location.
  ///
  /// This is called after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [onTertiaryTapUp] will be
  /// called, otherwise [onTertiaryTapCancel] will be called.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  final GestureTapDownCallback? onTertiaryTapDown;

  /// A pointer that will trigger a tap with a tertiary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers in the case of the tap gesture winning. If the tap gesture
  /// did not win, [onTertiaryTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  final GestureTapUpCallback? onTertiaryTapUp;

  /// The pointer that previously triggered [onTertiaryTapDown] will not end up
  /// causing a tap.
  ///
  /// This is called after [onTertiaryTapDown], and instead of
  /// [onTertiaryTapUp], if the tap gesture did not win.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  final GestureTapCancelCallback? onTertiaryTapCancel;

  /// A pointer that might cause a double tap has contacted the screen at a
  /// particular location.
  ///
  /// Triggered immediately after the down event of the second tap.
  ///
  /// If the user completes the double tap and the gesture wins, [onDoubleTap]
  /// will be called after this callback. Otherwise, [onDoubleTapCancel] will
  /// be called after this callback.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapDownCallback? onDoubleTapDown;

  /// The user has tapped the screen with a primary button at the same location
  /// twice in quick succession.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapCallback? onDoubleTap;

  /// The pointer that previously triggered [onDoubleTapDown] will not end up
  /// causing a double tap.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapCancelCallback? onDoubleTapCancel;

  /// The pointer has contacted the screen with a primary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down event.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [onLongPressStart] will be called after this callback. Otherwise,
  /// [onLongPressCancel] will be called after this callback.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onSecondaryLongPressDown], a similar callback but for a secondary button.
  ///  * [onTertiaryLongPressDown], a similar callback but for a tertiary button.
  ///  * [LongPressGestureRecognizer.onLongPressDown], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressDownCallback? onLongPressDown;

  /// A pointer that previously triggered [onLongPressDown] will not end up
  /// causing a long-press.
  ///
  /// This triggers once the gesture loses if [onLongPressDown] has previously
  /// been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [onLongPressStart] and [onLongPress] are called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPressCancel], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressCancelCallback? onLongPressCancel;

  /// Called when a long press gesture with a primary button has been recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately after) [onLongPressStart].
  /// The only difference between the two is that this callback does not
  /// contain details of the position at which the pointer initially contacted
  /// the screen.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPress], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressCallback? onLongPress;

  /// Called when a long press gesture with a primary button has been recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately before) [onLongPress].
  /// The only difference between the two is that this callback contains
  /// details of the position at which the pointer initially contacted the
  /// screen, whereas [onLongPress] does not.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPressStart], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressStartCallback? onLongPressStart;

  /// A pointer has been drag-moved after a long-press with a primary button.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPressMoveUpdate], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// A pointer that has triggered a long-press with a primary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately after) [onLongPressEnd].
  /// The only difference between the two is that this callback does not
  /// contain details of the state of the pointer when it stopped contacting
  /// the screen.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPressUp], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressUpCallback? onLongPressUp;

  /// A pointer that has triggered a long-press with a primary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately before) [onLongPressUp].
  /// The only difference between the two is that this callback contains
  /// details of the state of the pointer when it stopped contacting the
  /// screen, whereas [onLongPressUp] does not.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onLongPressEnd], which exposes this
  ///    callback at the gesture layer.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// The pointer has contacted the screen with a secondary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down event.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [onSecondaryLongPressStart] will be called after this callback. Otherwise,
  /// [onSecondaryLongPressCancel] will be called after this callback.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [onLongPressDown], a similar callback but for a secondary button.
  ///  * [onTertiaryLongPressDown], a similar callback but for a tertiary button.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressDown], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressDownCallback? onSecondaryLongPressDown;

  /// A pointer that previously triggered [onSecondaryLongPressDown] will not
  /// end up causing a long-press.
  ///
  /// This triggers once the gesture loses if [onSecondaryLongPressDown] has
  /// previously been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [onSecondaryLongPressStart] and [onSecondaryLongPress] are called instead.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressCancel], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressCancelCallback? onSecondaryLongPressCancel;

  /// Called when a long press gesture with a secondary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately after)
  /// [onSecondaryLongPressStart]. The only difference between the two is that
  /// this callback does not contain details of the position at which the
  /// pointer initially contacted the screen.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPress], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressCallback? onSecondaryLongPress;

  /// Called when a long press gesture with a secondary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately before)
  /// [onSecondaryLongPress]. The only difference between the two is that this
  /// callback contains details of the position at which the pointer initially
  /// contacted the screen, whereas [onSecondaryLongPress] does not.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressStart], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressStartCallback? onSecondaryLongPressStart;

  /// A pointer has been drag-moved after a long press with a secondary button.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressMoveUpdate], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressMoveUpdateCallback? onSecondaryLongPressMoveUpdate;

  /// A pointer that has triggered a long-press with a secondary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately after)
  /// [onSecondaryLongPressEnd]. The only difference between the two is that
  /// this callback does not contain details of the state of the pointer when
  /// it stopped contacting the screen.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressUp], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressUpCallback? onSecondaryLongPressUp;

  /// A pointer that has triggered a long-press with a secondary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately before)
  /// [onSecondaryLongPressUp]. The only difference between the two is that
  /// this callback contains details of the state of the pointer when it
  /// stopped contacting the screen, whereas [onSecondaryLongPressUp] does not.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onSecondaryLongPressEnd], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressEndCallback? onSecondaryLongPressEnd;

  /// The pointer has contacted the screen with a tertiary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down event.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [onTertiaryLongPressStart] will be called after this callback. Otherwise,
  /// [onTertiaryLongPressCancel] will be called after this callback.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [onLongPressDown], a similar callback but for a primary button.
  ///  * [onSecondaryLongPressDown], a similar callback but for a secondary button.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressDown], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressDownCallback? onTertiaryLongPressDown;

  /// A pointer that previously triggered [onTertiaryLongPressDown] will not
  /// end up causing a long-press.
  ///
  /// This triggers once the gesture loses if [onTertiaryLongPressDown] has
  /// previously been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [onTertiaryLongPressStart] and [onTertiaryLongPress] are called instead.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressCancel], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressCancelCallback? onTertiaryLongPressCancel;

  /// Called when a long press gesture with a tertiary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately after)
  /// [onTertiaryLongPressStart]. The only difference between the two is that
  /// this callback does not contain details of the position at which the
  /// pointer initially contacted the screen.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPress], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressCallback? onTertiaryLongPress;

  /// Called when a long press gesture with a tertiary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is called immediately before)
  /// [onTertiaryLongPress]. The only difference between the two is that this
  /// callback contains details of the position at which the pointer initially
  /// contacted the screen, whereas [onTertiaryLongPress] does not.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressStart], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressStartCallback? onTertiaryLongPressStart;

  /// A pointer has been drag-moved after a long press with a tertiary button.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressMoveUpdate], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressMoveUpdateCallback? onTertiaryLongPressMoveUpdate;

  /// A pointer that has triggered a long-press with a tertiary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately after)
  /// [onTertiaryLongPressEnd]. The only difference between the two is that
  /// this callback does not contain details of the state of the pointer when
  /// it stopped contacting the screen.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressUp], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressUpCallback? onTertiaryLongPressUp;

  /// A pointer that has triggered a long-press with a tertiary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is called immediately before)
  /// [onTertiaryLongPressUp]. The only difference between the two is that
  /// this callback contains details of the state of the pointer when it
  /// stopped contacting the screen, whereas [onTertiaryLongPressUp] does not.
  ///
  /// See also:
  ///
  ///  * [kTertiaryButton], the button this callback responds to.
  ///  * [LongPressGestureRecognizer.onTertiaryLongPressEnd], which exposes
  ///    this callback at the gesture layer.
  final GestureLongPressEndCallback? onTertiaryLongPressEnd;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move vertically.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragDownCallback? onVerticalDragDown;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move vertically.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragStartCallback? onVerticalDragStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// moving vertically has moved in the vertical direction.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragUpdateCallback? onVerticalDragUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving vertically is no longer in contact with the screen and
  /// was moving at a specific velocity when it stopped contacting the screen.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragEndCallback? onVerticalDragEnd;

  /// The pointer that previously triggered [onVerticalDragDown] did not
  /// complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragCancelCallback? onVerticalDragCancel;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move horizontally.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragDownCallback? onHorizontalDragDown;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move horizontally.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragStartCallback? onHorizontalDragStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// moving horizontally has moved in the horizontal direction.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragUpdateCallback? onHorizontalDragUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving horizontally is no longer in contact with the screen and
  /// was moving at a specific velocity when it stopped contacting the screen.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragEndCallback? onHorizontalDragEnd;

  /// The pointer that previously triggered [onHorizontalDragDown] did not
  /// complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragCancelCallback? onHorizontalDragCancel;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragDownCallback? onPanDown;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragStartCallback? onPanStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// moving has moved again.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragUpdateCallback? onPanUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving is no longer in contact with the screen and was moving
  /// at a specific velocity when it stopped contacting the screen.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragEndCallback? onPanEnd;

  /// The pointer that previously triggered [onPanDown] did not complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureDragCancelCallback? onPanCancel;

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  final GestureScaleStartCallback? onScaleStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureScaleEndCallback? onScaleEnd;

  /// The pointer is in contact with the screen and has pressed with sufficient
  /// force to initiate a force press. The amount of force is at least
  /// [ForcePressGestureRecognizer.startPressure].
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressStartCallback? onForcePressStart;

  /// The pointer is in contact with the screen and has pressed with the maximum
  /// force. The amount of force is at least
  /// [ForcePressGestureRecognizer.peakPressure].
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressPeakCallback? onForcePressPeak;

  /// A pointer is in contact with the screen, has previously passed the
  /// [ForcePressGestureRecognizer.startPressure] and is either moving on the
  /// plane of the screen, pressing the screen with varying forces or both
  /// simultaneously.
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressUpdateCallback? onForcePressUpdate;

  /// The pointer tracked by [onForcePressStart] is no longer in contact with the screen.
  ///
  /// This callback will only be fired on devices with pressure
  /// detecting screens.
  final GestureForcePressEndCallback? onForcePressEnd;

  /// How this gesture detector should behave during hit testing when deciding
  /// how the hit test propagates to children and whether to consider targets
  /// behind this one.
  ///
  /// This defaults to [HitTestBehavior.deferToChild] if [child] is not null and
  /// [HitTestBehavior.translucent] if child is null.
  ///
  /// See [HitTestBehavior] for the allowed values and their meanings.
  final HitTestBehavior? behavior;

  /// Whether to exclude these gestures from the semantics tree. For
  /// example, the long-press gesture for showing a tooltip is
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], gesture drag behavior will
  /// begin at the position where the drag gesture won the arena. If set to
  /// [DragStartBehavior.down] it will begin at the position where a down event
  /// is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// Only the [DragGestureRecognizer.onStart] callbacks for the
  /// [VerticalDragGestureRecognizer], [HorizontalDragGestureRecognizer] and
  /// [PanGestureRecognizer] are affected by this setting.
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  /// The kind of devices that are allowed to be recognized.
  ///
  /// If set to null, events from all device types will be recognized. Defaults to null.
  final Set<PointerDeviceKind>? supportedDevices;

  /// {@macro flutter.gestures.scale.trackpadScrollCausesScale}
  final bool trackpadScrollCausesScale;

  /// {@macro flutter.gestures.scale.trackpadScrollToScaleFactor}
  final Offset trackpadScrollToScaleFactor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTap: onTap,
      onTapCancel: onTapCancel,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onTertiaryTapDown: onTertiaryTapDown,
      onTertiaryTapUp: onTertiaryTapUp,
      onTertiaryTapCancel: onTertiaryTapCancel,
      onDoubleTapDown: onDoubleTapDown,
      onDoubleTap: onDoubleTap,
      onDoubleTapCancel: onDoubleTapCancel,
      onLongPressDown: onLongPressDown,
      onLongPressCancel: onLongPressCancel,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      onLongPressEnd: onLongPressEnd,
      onSecondaryLongPressDown: onSecondaryLongPressDown,
      onSecondaryLongPressCancel: onSecondaryLongPressCancel,
      onSecondaryLongPress: onSecondaryLongPress,
      onSecondaryLongPressStart: onSecondaryLongPressStart,
      onSecondaryLongPressMoveUpdate: onSecondaryLongPressMoveUpdate,
      onSecondaryLongPressUp: onSecondaryLongPressUp,
      onSecondaryLongPressEnd: onSecondaryLongPressEnd,
      onTertiaryLongPressDown: onTertiaryLongPressDown,
      onTertiaryLongPressCancel: onTertiaryLongPressCancel,
      onTertiaryLongPress: onTertiaryLongPress,
      onTertiaryLongPressStart: onTertiaryLongPressStart,
      onTertiaryLongPressMoveUpdate: onTertiaryLongPressMoveUpdate,
      onTertiaryLongPressUp: onTertiaryLongPressUp,
      onTertiaryLongPressEnd: onTertiaryLongPressEnd,
      onVerticalDragDown: onVerticalDragDown,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      onVerticalDragCancel: onVerticalDragCancel,
      onHorizontalDragDown: onHorizontalDragDown,
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragCancel: onHorizontalDragCancel,
      onPanDown: onPanDown,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      onForcePressStart: onForcePressStart,
      onForcePressPeak: onForcePressPeak,
      onForcePressUpdate: onForcePressUpdate,
      onForcePressEnd: onForcePressEnd,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      dragStartBehavior: dragStartBehavior,
      supportedDevices: supportedDevices,
      trackpadScrollCausesScale: trackpadScrollCausesScale,
      trackpadScrollToScaleFactor: trackpadScrollToScaleFactor,
      child: MouseRegion(
        onEnter: onEnter,
        onHover: onHover,
        onExit: onExit,
        cursor: cursor ?? SystemMouseCursors.click,
        opaque: opaque,
        hitTestBehavior: hitTestBehavior,
        child: child,
      ),
    );
  }
}
