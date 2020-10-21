![](https://user-gold-cdn.xitu.io/2019/10/18/16ddcea08cf56d0f?w=392&h=145&f=png&s=14253)
## 前言

入坑Flutter一年了，接触到Flutter也只是冰山一角，很多东西可能知道是怎么用的，但是不是很明白其中的原理，俗话说唯有深入，方能浅出。本系列将对Sliver相关源码一一进行分析，希望能够举一反三，不再惧怕Sliver。
![](https://user-gold-cdn.xitu.io/2019/11/12/16e5d24c7640c6ae?w=1200&h=900&f=png&s=1596820)
看完Flutter Sliver一生之敌 你将不会害怕使用Sliver，Sliver将成为你的一生之爱。欢迎加入Flutter Candies [![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)
* [ Flutter Sliver一生之敌 (ScrollView)](https://juejin.im/post/6844904008339947528)
* [Flutter Sliver一生之敌 (ExtendedList)](https://juejin.im/post/6844904015994552333)
* [Flutter Sliver你要的瀑布流小姐姐](https://juejin.im/post/6844904018804752391)
* [Flutter Sliver 锁住你的美](https://juejin.im/post/6861798947208953863)

下面是全部滚动的组件，以及他们的关系

| Widget   |     Build      |  Viewport | 
|----------|:-------------:|------:|
| SingleChildScrollView |  Scrollable | _SingleChildViewport |
| ScrollView |   Scrollable   |   ShrinkWrappingViewport/Viewport |

Sliver系列继承于ScrollView

| Widget   |     Extends      |
|----------|:-------------:|
| CustomScrollView |  ScrollView | 
| NestedScrollView |   CustomScrollView   |  
| ListView/GridView |  BoxScrollView => ScrollView  |  

简单讲滚动组件由Scrollable获取用户手势反馈，将滚动反馈和Slivers传递给Viewport计算出Sliver的位置。注意Sliver可以是单孩子(SliverPadding/SliverPersistentHeader/SliverToBoxAdapter等等)也可以是多孩子(SliverList/SliverGrid)。下面我们通过分析源码，探究其中奥秘。

## [ScrollView](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L50)

下面为build方法中的关键代码，这里是我们上面说的Scrollable，主要负责用户手势监听反馈。
``` dart
    final Scrollable scrollable = Scrollable(
      dragStartBehavior: dragStartBehavior,
      axisDirection: axisDirection,
      controller: scrollController,
      physics: physics,
      semanticChildCount: semanticChildCount,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return buildViewport(context, offset, axisDirection, slivers);
      },
    );
```
我们再看看buildViewport方法
``` dart
  @protected
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    if (shrinkWrap) {
      return ShrinkWrappingViewport(
        axisDirection: axisDirection,
        offset: offset,
        slivers: slivers,
      );
    }
    return Viewport(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      cacheExtent: cacheExtent,
      center: center,
      anchor: anchor,
    );
  }
``` 
根据shrinkWrap的不同，分成了2种Viewport

## [Scrollable](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scrollable.dart)

用于监听各种用户手势并实现滚动，下面为build方法中的关键代码。

``` dart
    //InheritedWidget组件，为了共享position数据
    Widget result = _ScrollableScope(
      scrollable: this,
      position: position,
      // TODO(ianh): Having all these global keys is sad.
      child: Listener(
        onPointerSignal: _receivedPointerSignal,
        child: RawGestureDetector(
          key: _gestureDetectorKey,
          gestures: _gestureRecognizers,
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: widget.excludeFromSemantics,
          child: Semantics(
            explicitChildNodes: !widget.excludeFromSemantics,
            child: IgnorePointer(
              key: _ignorePointerKey,
              ignoring: _shouldIgnorePointer,
              ignoringSemantics: false,
              //通过Listener监听手势，将滚动position通过viewportBuilder回调。
              child: widget.viewportBuilder(context, position),
            ),
          ),
        ),
      ),
    );
    
   //这里可以看到为什么安卓和ios上面对于滚动越界(overscrolls)时候的操作不一样    
   return _configuration.buildViewportChrome(context, result, widget.axisDirection);
```

安卓和fuchsia上面使用GlowingOverscrollIndicator来显示滚动不了之后的水波纹效果。
``` dart
  /// Wraps the given widget, which scrolls in the given [AxisDirection].
  ///
  /// For example, on Android, this method wraps the given widget with a
  /// [GlowingOverscrollIndicator] to provide visual feedback when the user
  /// overscrolls.
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    // When modifying this function, consider modifying the implementation in
    // _MaterialScrollBehavior as well.
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          child: child,
          axisDirection: axisDirection,
          color: _kDefaultGlowColor,
        );
    }
    return null;
  }
```

## [Viewport](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/viewport.dart#L45)

通过只显示(计算绘制)滚动视图中的一部分内容来实现滚动可视化设计，大大降低内存消耗。比如ListView可视区域为666像素，但其列表元素的总高度远远超过666像素，但实际上我们只是关心这个666像素中的元素(当然如果设置了CacheExtent，还要算上这个距离)

在Scrollview中将Scrollable滚动反馈以及Slivers传递给了Viewport。Viewport 是一个MultiChildRenderObjectWidget，lei了lei了，这是一个自绘多孩子的组件。直接找到createRenderObject方法，看到返回一个RenderViewport

### [RenderViewport](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/viewport.dart#L1109)

重头戏来了，我们看看构造参数有哪些。
``` dart
  RenderViewport({
    //主轴方向，默认向下
    AxisDirection axisDirection = AxisDirection.down,
    //纵轴方向，跟主轴方向以及有关系
    @required AxisDirection crossAxisDirection,
    //Scrollable中回调的用户反馈
    @required ViewportOffset offset,
    //当scrollOffset = 0，第一个child在viewport的位置（0 <= anchor <= 1.0），0.0在leading，1.0在trailing，0.5在中间
    double anchor = 0.0,
    //sliver孩子们
    List<RenderSliver> children,
    //The first child in the [GrowthDirection.forward] growth direction.
    //计算时候的基准，默认为第一个娃，这个参数估计极少有人使用
    RenderSliver center,
    //缓存区域大小
    double cacheExtent,
    //决定cacheExtent是实际大小还是根据viewport的百分比
    CacheExtentStyle cacheExtentStyle = CacheExtentStyle.pixel,
  })... {
    addAll(children);
    if (center == null && firstChild != null)
      _center = firstChild;
  }
```
可以看到构造中把全部孩子都加进入了，而且如果外部不传递center，center默认为第一个孩子。

**划重点代码分析**

#### sizedByParent
在Viewport中这个值永远返回true，
``` dart
  @override
  bool get sizedByParent => true;
```
来看看这个属性的[解释](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/object.dart#L1763)。即如果这个值为true，那么组件的大小只跟它的parent告诉它的大小constraints有关系，与它的 child 都无关.

就是说RenderViewport的大小约束是由它的parent告诉它的，跟里面的Slivers没有关系。说到这个我们看一个新手经常错误的代码。
``` dart
     Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '测试',
            ),
            ListView.builder(itemBuilder: (context,index){})
          ],
        ),
```
我们前面知道ListView最终是一个ScrollView,其中的Viewport在Column当中是无法知道自己的有效大小的，该代码的会导致Viewport的高度为无限大，将会报错(当然你这里可以把shrinkWrap设置为true，但是这样会导致ListView的全部元素都被计算，列表将失去滚动，这个我们后面会讲)

继续看[代码](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/object.dart#L1697)中看到，当sizedByParent为true的时候调用performResize方法，指定Size只根据constraints。
``` dart
    if (sizedByParent) {
      assert(() {
        _debugDoingThisResize = true;
        return true;
      }());
      try {
        performResize();
        assert(() {
          debugAssertDoesMeetConstraints();
          return true;
        }());
      } catch (e, stack) {
        _debugReportException('performResize', e, stack);
      }
      assert(() {
        _debugDoingThisResize = false;
        return true;
      }());
    }
```
#### performResize

看看RenderViewport的performResize中做了什么。有一大堆assert，就一句话，我不能无限大。最后将自己的size设置为constraints.biggest。
(size是自己的大小，constraints是parent给的限制)

``` dart
  @override
  void performResize() {
    assert(() {
      if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
        switch (axis) {
          case Axis.vertical:
            if (!constraints.hasBoundedHeight) {
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Vertical viewport was given unbounded height.'),
                ErrorDescription(
                  'Viewports expand in the scrolling direction to fill their container. '
                  'In this case, a vertical viewport was given an unlimited amount of '
                  'vertical space in which to expand. This situation typically happens '
                  'when a scrollable widget is nested inside another scrollable widget.'
                ),
                ErrorHint(
                  'If this widget is always nested in a scrollable widget there '
                  'is no need to use a viewport because there will always be enough '
                  'vertical space for the children. In this case, consider using a '
                  'Column instead. Otherwise, consider using the "shrinkWrap" property '
                  '(or a ShrinkWrappingViewport) to size the height of the viewport '
                  'to the sum of the heights of its children.'
                )
              ]);
            }
            if (!constraints.hasBoundedWidth) {
              throw FlutterError(
                'Vertical viewport was given unbounded width.\n'
                'Viewports expand in the cross axis to fill their container and '
                'constrain their children to match their extent in the cross axis. '
                'In this case, a vertical viewport was given an unlimited amount of '
                'horizontal space in which to expand.'
              );
            }
            break;
          case Axis.horizontal:
            if (!constraints.hasBoundedWidth) {
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Horizontal viewport was given unbounded width.'),
                ErrorDescription(
                  'Viewports expand in the scrolling direction to fill their container.'
                  'In this case, a horizontal viewport was given an unlimited amount of '
                  'horizontal space in which to expand. This situation typically happens '
                  'when a scrollable widget is nested inside another scrollable widget.'
                ),
                ErrorHint(
                  'If this widget is always nested in a scrollable widget there '
                  'is no need to use a viewport because there will always be enough '
                  'horizontal space for the children. In this case, consider using a '
                  'Row instead. Otherwise, consider using the "shrinkWrap" property '
                  '(or a ShrinkWrappingViewport) to size the width of the viewport '
                  'to the sum of the widths of its children.'
                )
              ]);
            }
            if (!constraints.hasBoundedHeight) {
              throw FlutterError(
                'Horizontal viewport was given unbounded height.\n'
                'Viewports expand in the cross axis to fill their container and '
                'constrain their children to match their extent in the cross axis. '
                'In this case, a horizontal viewport was given an unlimited amount of '
                'vertical space in which to expand.'
              );
            }
            break;
        }
      }
      return true;
    }());
    size = constraints.biggest;
    // We ignore the return value of applyViewportDimension below because we are
    // going to go through performLayout next regardless.
    switch (axis) {
      case Axis.vertical:
        offset.applyViewportDimension(size.height);
        break;
      case Axis.horizontal:
        offset.applyViewportDimension(size.width);
        break;
    }
  }
```

#### performLayout

负责布局RenderViewport的Children
``` dart
    //从size中得到主轴和纵轴的大小
    double mainAxisExtent;
    double crossAxisExtent;
    switch (axis) {
      case Axis.vertical:
        mainAxisExtent = size.height;
        crossAxisExtent = size.width;
        break;
      case Axis.horizontal:
        mainAxisExtent = size.width;
        crossAxisExtent = size.height;
        break;
    }

    //如果单Sliver孩子的viewport高度为100，anchor为0.5，centerOffsetAdjustment设置为50.0的话，当scroll offset is 0.0的时候，center会刚好在viewport中间。
    final double centerOffsetAdjustment = center.centerOffsetAdjustment;

    double correction;
    int count = 0;
    do {
      assert(offset.pixels != null);
      correction = _attemptLayout(mainAxisExtent, crossAxisExtent, offset.pixels + centerOffsetAdjustment);
      ///如果不为0.0的话，是因为child中有需要修正(这个我们将在后面系列中讲到，这里我们就简单认为在layout child过程中出现了问题)，我们需要改变scroll offset之后重新layout chilren。
      if (correction != 0.0) {
        offset.correctBy(correction);
      } else {
        ///告诉Scrollable 最小滚动距离和最大滚动距离
        if (offset.applyContentDimensions(
              math.min(0.0, _minScrollExtent + mainAxisExtent * anchor),
              math.max(0.0, _maxScrollExtent - mainAxisExtent * (1.0 - anchor)),
           ))
          break;
      }
      count += 1;
    } while (count < _maxLayoutCycles);
```
如果超过最大次数，children还是layout还是有问题的话，将警告提示。

下面我们看看_attemptLayout方法中做了什么。
``` dart   
  double _attemptLayout(double mainAxisExtent, double crossAxisExtent, double correctedOffset) {
    assert(!mainAxisExtent.isNaN);
    assert(mainAxisExtent >= 0.0);
    assert(crossAxisExtent.isFinite);
    assert(crossAxisExtent >= 0.0);
    assert(correctedOffset.isFinite);
    _minScrollExtent = 0.0;
    _maxScrollExtent = 0.0;
    _hasVisualOverflow = false;

    //centerOffset的数值将使用anchor和offset.pixels + centerOffsetAdjustment进行修正。前面有讲
    final double centerOffset = mainAxisExtent * anchor - correctedOffset;
    //反向RemainingPaintExtent，就是center之前还有多少距离可以拿来绘制
    final double reverseDirectionRemainingPaintExtent = centerOffset.clamp(0.0, mainAxisExtent);
    //正向RemainingPaintExtent，就是center之后还有多少距离可以拿来绘制
    final double forwardDirectionRemainingPaintExtent = (mainAxisExtent - centerOffset).clamp(0.0, mainAxisExtent);

    switch (cacheExtentStyle) {
      case CacheExtentStyle.pixel:
        _calculatedCacheExtent = cacheExtent;
        break;
      case CacheExtentStyle.viewport:
        _calculatedCacheExtent = mainAxisExtent * cacheExtent;
        break;
    }
    ///总的计算区域包含前后2个cacheExtent
    final double fullCacheExtent = mainAxisExtent + 2 * _calculatedCacheExtent;
    ///加上cacheExtent的center位置，跟前面的比就是多了cache
    final double centerCacheOffset = centerOffset + _calculatedCacheExtent;
     //反向RemainingPaintExtent，就是center之前还有多少距离可以拿来绘制，跟前面的比就是多了cache
    final double reverseDirectionRemainingCacheExtent = centerCacheOffset.clamp(0.0, fullCacheExtent);
     //正向RemainingPaintExtent，就是center之后还有多少距离可以拿来绘制，跟前面的比就是多了cache
    final double forwardDirectionRemainingCacheExtent = (fullCacheExtent - centerCacheOffset).clamp(0.0, fullCacheExtent);

    final RenderSliver leadingNegativeChild = childBefore(center);
    ///如果在center之前还有child，将向前layout child，计算前面布局前面的child
    if (leadingNegativeChild != null) {
      // negative scroll offsets
      final double result = layoutChildSequence(
        child: leadingNegativeChild,
        scrollOffset: math.max(mainAxisExtent, centerOffset) - mainAxisExtent,
        overlap: 0.0,
        layoutOffset: forwardDirectionRemainingPaintExtent,
        remainingPaintExtent: reverseDirectionRemainingPaintExtent,
        mainAxisExtent: mainAxisExtent,
        crossAxisExtent: crossAxisExtent,
        growthDirection: GrowthDirection.reverse,
        advance: childBefore,
        remainingCacheExtent: reverseDirectionRemainingCacheExtent,
        cacheOrigin: (mainAxisExtent - centerOffset).clamp(-_calculatedCacheExtent, 0.0),
      );
      if (result != 0.0)
        return -result;
    }

    ///布局center后面的child
    // positive scroll offsets
    return layoutChildSequence(
      child: center,
      scrollOffset: math.max(0.0, -centerOffset),
      overlap: leadingNegativeChild == null ? math.min(0.0, -centerOffset) : 0.0,
      layoutOffset: centerOffset >= mainAxisExtent ? centerOffset: reverseDirectionRemainingPaintExtent,
      remainingPaintExtent: forwardDirectionRemainingPaintExtent,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
      growthDirection: GrowthDirection.forward,
      advance: childAfter,
      remainingCacheExtent: forwardDirectionRemainingCacheExtent,
      cacheOrigin: centerOffset.clamp(-_calculatedCacheExtent, 0.0),
    );
  }
```     

注意scrollOffset ，在向前和向后layout的时候不一样，
一个是 math.max(mainAxisExtent, centerOffset) - mainAxisExtent
一个是 math.max(0.0, -centerOffset)
我们有说过center其实是scrolloffset为0的基准，viewport里面如果有多个slivers，我们可以指定其中一个为center(默认第一个为center)，那么想前滚centerOffset会变大，想后滚centerOffset会变成负数。感觉还是有点抽象，下面给一个栗子，我给第2个sliver增加了key，并且把CustomScrollView的center赋值为这个key。小声逼逼，Center这个参数我估计百分之99的人没有用过，用过的请留言，我看看有多少人知道这个。

```  dart
CustomScrollView(
        center: key,
        slivers: <Widget>[
        SliverList(),
        SliverGrid(key:key),
``` 
运行起来初始centerOffset为0的时候SliverGrid在初始位置。
![](https://user-gold-cdn.xitu.io/2019/12/1/16ec0165ab14f0fb?w=1080&h=1920&f=jpeg&s=42833)
向前滚动，可以看到我们得到了逆向的SliverList，从我们的参数中也可以验证到。而offset.pixels（ScollView的滚动位置）当然也为0.(而不是你们想的SliverList的高度)
![](https://user-gold-cdn.xitu.io/2019/12/1/16ec016668e215a4?w=1080&h=1920&f=jpeg&s=50301)

再看下layoutChildSequence方法，注意到advance方法，向前其实调用的是childBefore，向后是调用的childAfter
```  dart
  double layoutChildSequence({
    @required RenderSliver child,
    @required double scrollOffset,
    @required double overlap,
    @required double layoutOffset,
    @required double remainingPaintExtent,
    @required double mainAxisExtent,
    @required double crossAxisExtent,
    @required GrowthDirection growthDirection,
    @required RenderSliver advance(RenderSliver child),
    @required double remainingCacheExtent,
    @required double cacheOrigin,
  }) {
    assert(scrollOffset.isFinite);
    assert(scrollOffset >= 0.0);
    final double initialLayoutOffset = layoutOffset;
    final ScrollDirection adjustedUserScrollDirection =
        applyGrowthDirectionToScrollDirection(offset.userScrollDirection, growthDirection);
    assert(adjustedUserScrollDirection != null);
    double maxPaintOffset = layoutOffset + overlap;
    double precedingScrollExtent = 0.0;

    while (child != null) {
      final double sliverScrollOffset = scrollOffset <= 0.0 ? 0.0 : scrollOffset;
      // If the scrollOffset is too small we adjust the paddedOrigin because it
      // doesn't make sense to ask a sliver for content before its scroll
      // offset.
      final double correctedCacheOrigin = math.max(cacheOrigin, -sliverScrollOffset);
      final double cacheExtentCorrection = cacheOrigin - correctedCacheOrigin;

      assert(sliverScrollOffset >= correctedCacheOrigin.abs());
      assert(correctedCacheOrigin <= 0.0);
      assert(sliverScrollOffset >= 0.0);
      assert(cacheExtentCorrection <= 0.0);
      
      //输入
      child.layout(SliverConstraints(
        axisDirection: axisDirection,
        growthDirection: growthDirection,
        userScrollDirection: adjustedUserScrollDirection,
        scrollOffset: sliverScrollOffset,
        precedingScrollExtent: precedingScrollExtent,
        overlap: maxPaintOffset - layoutOffset,
        remainingPaintExtent: math.max(0.0, remainingPaintExtent - layoutOffset + initialLayoutOffset),
        crossAxisExtent: crossAxisExtent,
        crossAxisDirection: crossAxisDirection,
        viewportMainAxisExtent: mainAxisExtent,
        remainingCacheExtent: math.max(0.0, remainingCacheExtent + cacheExtentCorrection),
        cacheOrigin: correctedCacheOrigin,
      ), parentUsesSize: true);
      //输出
      final SliverGeometry childLayoutGeometry = child.geometry;
      assert(childLayoutGeometry.debugAssertIsValid());

      // If there is a correction to apply, we'll have to start over.
      if (childLayoutGeometry.scrollOffsetCorrection != null)
        return childLayoutGeometry.scrollOffsetCorrection;

      // We use the child's paint origin in our coordinate system as the
      // layoutOffset we store in the child's parent data.
      final double effectiveLayoutOffset = layoutOffset + childLayoutGeometry.paintOrigin;

      // `effectiveLayoutOffset` becomes meaningless once we moved past the trailing edge
      // because `childLayoutGeometry.layoutExtent` is zero. Using the still increasing
      // 'scrollOffset` to roughly position these invisible slivers in the right order.
      if (childLayoutGeometry.visible || scrollOffset > 0) {
        updateChildLayoutOffset(child, effectiveLayoutOffset, growthDirection);
      } else {
        updateChildLayoutOffset(child, -scrollOffset + initialLayoutOffset, growthDirection);
      }

      //更新最大绘制位置
      maxPaintOffset = math.max(effectiveLayoutOffset + childLayoutGeometry.paintExtent, maxPaintOffset);
      scrollOffset -= childLayoutGeometry.scrollExtent;
      //前一个child的滚动距离
      precedingScrollExtent += childLayoutGeometry.scrollExtent;
      layoutOffset += childLayoutGeometry.layoutExtent;
      if (childLayoutGeometry.cacheExtent != 0.0) {
        remainingCacheExtent -= childLayoutGeometry.cacheExtent - cacheExtentCorrection;
        cacheOrigin = math.min(correctedCacheOrigin + childLayoutGeometry.cacheExtent, 0.0);
      }
      
      // 更新_maxScrollExtent和_minScrollExtent
      // https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/viewport.dart#L1449
      updateOutOfBandData(growthDirection, childLayoutGeometry);

      // move on to the next child
      // layout下一个child
      child = advance(child);
    }

    // we made it without a correction, whee!
    //完美，全部的children都没有错误
    return 0.0;
  }
 ```    
 SliverConstraints为layout child的输入，SliverGeometry为layout child之后的输出，layout之后viewport将更新_maxScrollExtent和_minScrollExtent，然后layout下一个sliver。至于child.layout方法里面内容，我们将会在下一个章当中讲到。
 
### [RenderShrinkWrappingViewport](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/viewport.dart#L1638)

当我们把shrinkWrap设置为true的时候，最终的Viewport使用的是RenderShrinkWrappingViewport。那么我们看看其中的区别是什么。
先看看官方对[shrinkWrap](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L186)参数的解释。设置shrinkWrap为true，viewport的大小将不是由它的父亲而决定，而是由它自己决定。我们经常碰到由人使用ListView嵌套ListView的情况， 外面的ListView在layout child的时候需要知道里面ListView的大小，而我们前面知道ListView中的Viewport的大小是由它parent告诉它的。

parent：hi, child,你有多大，我给你一个无限纵轴大小的限制。

child: hi, parent，我也不知道啊，你不告诉我，我的viewport有多大。那么我只能将我的全部child都layout出来才知道我总的大小了。那我得换一个viewport了，RenderShrinkWrappingViewport才能知道计算出我的总高度。

由于ListView的parent无法告诉它的child ListView的可丈量大小，所以我们必须设置shrinkWrap为true，内部使用RenderShrinkWrappingViewport计算。

由于RenderShrinkWrappingViewport的大小不再只由parent决定，所以不再调用performResize方法。那么我们来关注下performLayout方法。

#### performLayout
 ``` dart    
  @override
  void performLayout() {
    if (firstChild == null) {
      switch (axis) {
        case Axis.vertical:
          //如果是竖直，你起码要告诉我水平最大限制吧？
          assert(constraints.hasBoundedWidth);
          size = Size(constraints.maxWidth, constraints.minHeight);
          break;
           //如果是水平，你起码要告诉我垂直最大限制吧？
        case Axis.horizontal:
          assert(constraints.hasBoundedHeight);
          size = Size(constraints.minWidth, constraints.maxHeight);
          break;
      }
      offset.applyViewportDimension(0.0);
      _maxScrollExtent = 0.0;
      _shrinkWrapExtent = 0.0;
      _hasVisualOverflow = false;
      offset.applyContentDimensions(0.0, 0.0);
      return;
    }

    double mainAxisExtent;
    double crossAxisExtent;
    switch (axis) {
      case Axis.vertical:
       //如果是竖直，你起码要告诉我水平最大限制吧？说到这个我想起来了Flutter中为啥没有支持水平和垂直都能滚动的容器了。
        assert(constraints.hasBoundedWidth);
        mainAxisExtent = constraints.maxHeight;
        crossAxisExtent = constraints.maxWidth;
        break;
      case Axis.horizontal:
        assert(constraints.hasBoundedHeight);
        //如果是水平，你起码要告诉我垂直最大限制吧？
        mainAxisExtent = constraints.maxWidth;
        crossAxisExtent = constraints.maxHeight;
        break;
    }

    double correction;
    double effectiveExtent;
    do {
      assert(offset.pixels != null);
      correction = _attemptLayout(mainAxisExtent, crossAxisExtent, offset.pixels);
      if (correction != 0.0) {
        offset.correctBy(correction);
      } else {
        switch (axis) {
          case Axis.vertical:
            effectiveExtent = constraints.constrainHeight(_shrinkWrapExtent);
            break;
          case Axis.horizontal:
            effectiveExtent = constraints.constrainWidth(_shrinkWrapExtent);
            break;
        }
        final bool didAcceptViewportDimension = offset.applyViewportDimension(effectiveExtent);
        final bool didAcceptContentDimension = offset.applyContentDimensions(0.0, math.max(0.0, _maxScrollExtent - effectiveExtent));
        if (didAcceptViewportDimension && didAcceptContentDimension)
          break;
      }
    } while (true);
    switch (axis) {
      case Axis.vertical:
        size = constraints.constrainDimensions(crossAxisExtent, effectiveExtent);
        break;
      case Axis.horizontal:
        size = constraints.constrainDimensions(effectiveExtent, crossAxisExtent);
        break;
    }
  }
 ``` 
 _maxScrollExtent和
_shrinkWrapExtent都是关键先生。当mainAxisExtent不为double.Infinity(无限大)的时候，其实效果跟Viewport里面计算(除掉Center相关)是一样; 当mainAxisExtent为double.Infinity(无限大)，我们将会将全部的child都layout出来获得总的大小

[关键代码](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/viewport.dart#L1638)
 ``` dart
  @override
  void updateOutOfBandData(GrowthDirection growthDirection, SliverGeometry childLayoutGeometry) {
    assert(growthDirection == GrowthDirection.forward);
    _maxScrollExtent += childLayoutGeometry.scrollExtent;
    if (childLayoutGeometry.hasVisualOverflow)
      _hasVisualOverflow = true;
    _shrinkWrapExtent += childLayoutGeometry.maxPaintExtent;
  }
 ```   
这里也就是为啥我们之前说Column里面或者ListView放ListView(子)，ListView(子)会全部元素都build，并且失去滚动的原因。

## 剧透
这一章看起来有些枯燥，都是源码分析。下一章(Flutter Sliver一生之敌 (ExtendedList))，我们将顺着ListView/GridView=> SliverList/SliverGrid => RenderSliverList/RenderSliverGrid的感情线，了解最终Sliver是怎么将children绘制出来的。下一章将不只是枯燥的源码分析，我们将举一反N，告诉你如何**[处理图片列表内存爆炸闪退](https://github.com/fluttercandies/extended_image/blob/master/example/lib/pages/photo_view_demo.dart#L91)**，将告诉你列表元素特殊的layout方式等等。


## 结语

[ExtendedList](https://github.com/fluttercandies/extended_list)          [WaterfallFlow](https://github.com/fluttercandies/waterfall_flow) 和  [LoadingMoreList](https://github.com/fluttercandies/loading_more_list) 都是可以食用的状态。等不及的小伙伴可以提前食用，特别是[图片列表内存过大而导致闪退的小伙伴可以先看demo,先解决掉一直折磨大家的问题](https://github.com/fluttercandies/extended_image/blob/e1577bc4d0b57c725110a9d886703b98a72772b5/example/lib/pages/photo_view_demo.dart#L91)

欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果[![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)

