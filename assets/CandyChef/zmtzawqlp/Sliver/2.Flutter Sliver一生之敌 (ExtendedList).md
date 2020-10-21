![](https://user-gold-cdn.xitu.io/2019/10/18/16ddcea08cf56d0f?w=392&h=145&f=png&s=14253)
## 前言

接着上一章[Flutter Sliver一生之敌 (ScrollView)](https://juejin.im/post/6844904008339947528)，我们这章将沿着ListView/GridView => SliverList/SliverGrid => RenderSliverList/RenderSliverGrid的感情线，梳理列表计算的最终一公里代码,举一反N。

欢迎加入Flutter Candies [![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

* [ Flutter Sliver一生之敌 (ScrollView)](https://juejin.im/post/6844904008339947528)
* [Flutter Sliver一生之敌 (ExtendedList)](https://juejin.im/post/6844904015994552333)
* [Flutter Sliver你要的瀑布流小姐姐](https://juejin.im/post/6844904018804752391)
* [Flutter Sliver 锁住你的美](https://juejin.im/post/6861798947208953863)

## Sliver的布局输入和输出
在讲解布局代码之前，先要了解下Sliver布局的输入和输出

### [SliverConstraints](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver.dart#L94) 
Sliver布局的输入，就是Viewport告诉我们的约束。
``` dart
class SliverConstraints extends Constraints {
  /// Creates sliver constraints with the given information.
  ///
  /// All of the argument must not be null.
  const SliverConstraints({
    //滚动的方向
    @required this.axisDirection,
    //这个是给center使用的，center之前的sliver是颠倒的
    @required this.growthDirection,
    //用户手势的方向
    @required this.userScrollDirection,
    //滚动的偏移量，注意这里是针对这个Sliver的，而且非整个Slivers的总滚动偏移量
    @required this.scrollOffset,
    //前面Slivers的总的大小
    @required this.precedingScrollExtent,
    //为pinned和floating设计的，如果前一个Sliver绘制大小为100，但是布局大小只有50，那么这个Sliver的overlap为50.
    @required this.overlap,
    //还有多少内容可以绘制，参考viewport以及cache。比如多Slivers的时候，前一个占了100，那么后面能绘制的区域就要减掉前面绘制的区域大小，得到剩余的绘制区域大小
    @required this.remainingPaintExtent,
    //纵轴的大小
    @required this.crossAxisExtent,
    //纵轴的方向，这里会影响GridView同一行元素的摆放顺序，是0~x，还是x~0
    @required this.crossAxisDirection,
    //viewport中还有多少内容可以绘制
    @required this.viewportMainAxisExtent,
    //剩余的缓存区域大小
    @required this.remainingCacheExtent,
    //相对于scrollOffset缓存区域大小
    @required this.cacheOrigin,
  })
``` 
### [SliverGeometry](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver.dart#L508)

Sliver布局的输出，将会反馈给Viewport。

```  dart
@immutable
class SliverGeometry extends Diagnosticable {
  /// Creates an object that describes the amount of space occupied by a sliver.
  ///
  /// If the [layoutExtent] argument is null, [layoutExtent] defaults to the
  /// [paintExtent]. If the [hitTestExtent] argument is null, [hitTestExtent]
  /// defaults to the [paintExtent]. If [visible] is null, [visible] defaults to
  /// whether [paintExtent] is greater than zero.
  ///
  /// The other arguments must not be null.
  const SliverGeometry({
    //预估的Sliver能够滚动大小
    this.scrollExtent = 0.0,
    //对后一个的overlap属性有影响，它小于[SliverConstraints.remainingPaintExtent],为Sliver在viewport范围(包含cache)内第一个元素到最后一个元素的大小
    this.paintExtent = 0.0,
    //相对Sliver位置的绘制起点
    this.paintOrigin = 0.0,
    //这个sliver在viewport的第一个显示位置到下一个sliver的第一个显示位置的大小
    double layoutExtent,
    //最大能绘制的总大小，这个参数是用于[SliverConstraints.remainingPaintExtent] 是无穷大的，就是使用在shrink-wrapping viewport中
    this.maxPaintExtent = 0.0,
    //如果sliver被pinned在边界的时候，这个大小为Sliver的自身的高度。其他情况为0
    this.maxScrollObstructionExtent = 0.0,
    //点击有效区域的大小，默认为paintExtent
    double hitTestExtent,
    //可见，paintExtent为0不可见。
    bool visible,
    //是否需要做clip，免得chidren溢出
    this.hasVisualOverflow = false,
    //viewport layout sliver的时候，如果sliver出现了一些问题，那么这个值将不等于0，通过这个值来修正整个滚动的ScrollOffset
    this.scrollOffsetCorrection,
    //该Sliver使用了多少[SliverConstraints.remainingCacheExtent]，针对多Slivers的情况
    double cacheExtent,
  })
``` 
大概讲解了这些参数的意义，可能还是不太明白，在后面的源码中使用中还会根据场景进行讲解。

## [BoxScrollView](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L491)

| Widget   |     Extends      |
|----------|:-------------:|
| ListView/GridView |  BoxScrollView => ScrollView  |  

ListView 和 GirdView 都继承与BoxScrollView，我们先看看BoxScrollView跟ScrollView有什么区别。

[关键代码](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L524)
``` dart
/// The amount of space by which to inset the children.
  final EdgeInsetsGeometry padding;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    /// 这个方法被ListView/GirdView 实现
    Widget sliver = buildChildLayout(context);
    EdgeInsetsGeometry effectivePadding = padding;
    if (padding == null) {
      final MediaQueryData mediaQuery = MediaQuery.of(context, nullOk: true);
      if (mediaQuery != null) {
        // Automatically pad sliver with padding from MediaQuery.
        final EdgeInsets mediaQueryHorizontalPadding =
            mediaQuery.padding.copyWith(top: 0.0, bottom: 0.0);
        final EdgeInsets mediaQueryVerticalPadding =
            mediaQuery.padding.copyWith(left: 0.0, right: 0.0);
        // Consume the main axis padding with SliverPadding.
        effectivePadding = scrollDirection == Axis.vertical
            ? mediaQueryVerticalPadding
            : mediaQueryHorizontalPadding;
        // Leave behind the cross axis padding.
        sliver = MediaQuery(
          data: mediaQuery.copyWith(
            padding: scrollDirection == Axis.vertical
                ? mediaQueryHorizontalPadding
                : mediaQueryVerticalPadding,
          ),
          child: sliver,
        );
      }
    }

    if (effectivePadding != null)
      sliver = SliverPadding(padding: effectivePadding, sliver: sliver);
    return <Widget>[ sliver ];
  }

  /// Subclasses should override this method to build the layout model.
  @protected
  /// 这个方法被ListView/GirdView 实现
  Widget buildChildLayout(BuildContext context);
```
可以看出来，只是多包了一层SliverPadding，最后返回的<Widget>[ sliver ]也说明，其实ListView和GridView 跟CustomScrollView相比，前者是单个Sliver,后者可为多个Slivers.

## [ListView](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L844) 

[关键代码](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L1202)

在BoxScrollView的buildSlivers方法中调用了buildChildLayout，下面是在ListView中的实现。可以看到根据itemExtent来分别返回了SliverList和SliverFixedExtentList 2种Sliver。
```dart
  @override
  Widget buildChildLayout(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        delegate: childrenDelegate,
        itemExtent: itemExtent,
      );
    }
    return SliverList(delegate: childrenDelegate);
  }
```

### [SliverList](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/sliver.dart#L809)

``` dart
class SliverList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children in a linear array.
  const SliverList({
    Key key,
    @required SliverChildDelegate delegate,
  }) : super(key: key, delegate: delegate);

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context;
    return RenderSliverList(childManager: element);
  }
}
```
### [RenderSliverList](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L36)


#### Sliver布局
RenderSliverList中的performLayout (https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L46)方法是用于布局children，在讲解代码之前我们先看一下单个Sliver的children布局的情况。

![](https://user-gold-cdn.xitu.io/2019/11/29/16eb68252513f2b4?w=361&h=554&f=png&s=26660)

图中绿色的为我们能看到的部分，黄色是缓存区域，灰色为应该回收掉的部分。

* [layout 准备开始](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L47)
``` dart
    //指示开始
    childManager.didStartLayout();
    //指示是否可以添加新的child
    childManager.setDidUnderflow(false);
    
    //constraints就是viewport给我们的布局限制，也就是布局输入
    //滚动位置包含cache，布局区域开始位置
    final double scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    //绘制整个区域大小包含缓存区域，就是图中黄色和绿色部分
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    //布局区域结束位置
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    //获取到child的限制，如果是垂直滚动的列表，高度应该是无限大double.infinity
    final BoxConstraints childConstraints = constraints.asBoxConstraints();
    //从第一个child开始向后需要回收的孩子个数，图中灰色部分
    int leadingGarbage = 0;
    //从最后一个child开始向前需要回收的孩子个数，图中灰色部分
    int trailingGarbage = 0;
    //是否滚动到最后
    bool reachedEnd = false;
    
    //如果列表里面没有一个child，我们将尝试加入一个，如果加入失败，那么整个Sliver无内容
    if (firstChild == null) {
      if (!addInitialChild()) {
        // There are no children.
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }
```

* [向前计算的情况](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L95)，(垂直滚动的列表)是列表想前滚动。由于灰色部分的child会被移除，所以当我们向前滚动的时候，我们需要根据现在的滚动位置来查看是否需要在前面插入child。
``` dart
    // Find the last child that is at or before the scrollOffset.
    RenderBox earliestUsefulChild = firstChild;
    //当第一个child的layoutOffset小于我们的滚动位置的时候，说明前面是空的，如果在第一个child的签名插入一个新的child来填充
    for (double earliestScrollOffset =
    childScrollOffset(earliestUsefulChild);
        earliestScrollOffset > scrollOffset;
        earliestScrollOffset = childScrollOffset(earliestUsefulChild)) {
      // We have to add children before the earliestUsefulChild.
      // 这里就是在插入新的child
      earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
      //处理当前面已经没有child的时候
      if (earliestUsefulChild == null) {
        final SliverMultiBoxAdaptorParentData childParentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        
        //已经到0.0的位置了，所以不需要再向前找了，break
        if (scrollOffset == 0.0) {
          // insertAndLayoutLeadingChild only lays out the children before
          // firstChild. In this case, nothing has been laid out. We have
          // to lay out firstChild manually.
          firstChild.layout(childConstraints, parentUsesSize: true);
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;
          break;
        } else {
          // We ran out of children before reaching the scroll offset.
          // We must inform our parent that this sliver cannot fulfill
          // its contract and that we need a scroll offset correction.
          // 这里就是我们上一章讲的，出现出错了。将scrollOffsetCorrection设置为不为0，传递给viewport，这样它会整体重新移除掉这个差值，重新进行layout布局。
          geometry = SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          return;
        }
      }

      /// 滚动的位置减掉firstChild的大小，用来继续计算是否还需要插入更多child来补足前面。
      final double firstChildScrollOffset = earliestScrollOffset - paintExtentOf(firstChild);
      // firstChildScrollOffset may contain double precision error
      // 同样的道理，如果发现最终减掉之后，数值小于0.0(precisionErrorTolerance这是一个接近0.0的极小数)的话，肯定是不对的，所以又告诉viewport移除掉差值，重新布局
      if (firstChildScrollOffset < -precisionErrorTolerance) {
        // The first child doesn't fit within the viewport (underflow) and
        // there may be additional children above it. Find the real first child
        // and then correct the scroll position so that there's room for all and
        // so that the trailing edge of the original firstChild appears where it
        // was before the scroll offset correction.
        // TODO(hansmuller): do this work incrementally, instead of all at once,
        // i.e. find a way to avoid visiting ALL of the children whose offset
        // is < 0 before returning for the scroll correction.
        double correction = 0.0;
        while (earliestUsefulChild != null) {
          assert(firstChild == earliestUsefulChild);
          correction += paintExtentOf(firstChild);
          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
        }
        geometry = SliverGeometry(
          scrollOffsetCorrection: correction - earliestScrollOffset,
        );
        final SliverMultiBoxAdaptorParentData childParentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        return;
      }
      // ok，这里就是正常的情况
      final SliverMultiBoxAdaptorParentData childParentData = earliestUsefulChild.parentData as SliverMultiBoxAdaptorParentData;
      // 设置child绘制的开始点
      childParentData.layoutOffset = firstChildScrollOffset;
      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }
```
* advance 方法(https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L181)

向后移动child，如果没有了返回false
``` dart
    bool inLayoutRange = true;
    RenderBox child = earliestUsefulChild;
    int index = indexOf(child);
    double endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
    bool advance() { // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout)
        inLayoutRange = false;
      child = childAfter(child);
      ///不在render tree里面
      if (child == null)
        inLayoutRange = false;
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          //不在树里面，尝试新增进去
          child = insertAndLayoutChild(childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.
          child.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      //设置绘制位置
      childParentData.layoutOffset = endScrollOffset;
      assert(childParentData.index == index);
      //设置endScrollOffset为child的绘制结束位置
      endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
      return true;
    }
```

* [找到离scrollOffset置最近的一个child](https://github.com/flutter/flutter/blob/a5f9b3b036db83b864e336149d1f40b2921a5eab/packages/flutter/lib/src/rendering/sliver_list.dart#L217-L234)

当向后滚动的时候，第一个child也许不是离scrollOffset最近的，所以我们需要向后找，找到这个最近的。

``` dart
    // Find the first child that ends after the scroll offset.
    while (endScrollOffset < scrollOffset) {
      //如果是小于，说明需要被回收，这里+1记录一下。
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        //找到最后都没有满足的话，将以最后一个child为准
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent = childScrollOffset(lastChild) + paintExtentOf(lastChild);
        geometry = SliverGeometry(
          scrollExtent: extent,
          paintExtent: 0.0,
          maxPaintExtent: extent,
        );
        return;
      }
    }
```

* [向后处理child](https://github.com/flutter/flutter/blob/a5f9b3b036db83b864e336149d1f40b2921a5eab/packages/flutter/lib/src/rendering/sliver_list.dart#L237)直到布局区域的结束位置。

``` dart
    // Now find the first child that ends after our end.
    // 直到布局区域的结束位置
    while (endScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    //到上面位置是需要布局的最后一个child，所以在它之后的child就是需要被回收的
    if (child != null) {
      child = childAfter(child);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child);
      }
    }
```

* [回收children](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L256)

``` dart
    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.
    // 使用之前计算出来的回收参数
    collectGarbage(leadingGarbage, trailingGarbage);
 
  @protected
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= leadingGarbage + trailingGarbage);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      //从第一个向后删除
      while (leadingGarbage > 0) {
        _destroyOrCacheChild(firstChild);
        leadingGarbage -= 1;
      }
      //从最后一个向前删除
      while (trailingGarbage > 0) {
        _destroyOrCacheChild(lastChild);
        trailingGarbage -= 1;
      }
      // Ask the child manager to remove the children that are no longer being
      // kept alive. (This should cause _keepAliveBucket to change, so we have
      // to prepare our list ahead of time.)
      _keepAliveBucket.values.where((RenderBox child) {
        final SliverMultiBoxAdaptorParentData childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
        return !childParentData.keepAlive;
      }).toList().forEach(_childManager.removeChild);
      assert(_keepAliveBucket.values.where((RenderBox child) {
        final SliverMultiBoxAdaptorParentData childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
        return !childParentData.keepAlive;
      }).isEmpty);
    });
  }
  
  void _destroyOrCacheChild(RenderBox child) {
    final SliverMultiBoxAdaptorParentData childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
    //如果child被标记为缓存的话，从tree中移除并且放入缓存中
    if (childParentData.keepAlive) {
      assert(!childParentData._keptAlive);
      remove(child);
      _keepAliveBucket[childParentData.index] = child;
      child.parentData = childParentData;
      super.adoptChild(child);
      childParentData._keptAlive = true;
    } else {
      assert(child.parent == this);
      //直接移除
      _childManager.removeChild(child);
      assert(child.parent == null);
    }
  }
```

* [计算sliver的输出](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_list.dart#L260)

``` dart
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    double estimatedMaxScrollOffset;
    //以及到底了，直接使用最后一个child的绘制结束位置
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
    // 计算出估计最大值
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild),
        lastIndex: indexOf(lastChild),
        leadingScrollOffset: childScrollOffset(firstChild),
        trailingScrollOffset: endScrollOffset,
      );
      assert(estimatedMaxScrollOffset >= endScrollOffset - childScrollOffset(firstChild));
    }
    //根据remainingPaintExtent算出当前消耗了的绘制区域大小
    final double paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    //根据remainingCacheExtent算出当前消耗了的缓存绘制区域大小
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    //布局区域结束位置
    final double targetEndScrollOffsetForPaint = constraints.scrollOffset + constraints.remainingPaintExtent;
    //将输出反馈给Viewport，viewport根据sliver的输出，如果这个sliver已经没有内容了，再布局下一个
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      //是否需要clip
      hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint || constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    // 2者相等说明已经这个sliver的底部了
    if (estimatedMaxScrollOffset == endScrollOffset)
      childManager.setDidUnderflow(true);
    //通知完成layout
    //这里会通过[SliverChildDelegate.didFinishLayout] 将第一个index和最后一个index传递出去，可以用追踪
    childManager.didFinishLayout();

```
[估计最大值默认实现](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/sliver.dart#L1341)
``` dart
  static double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
    int childCount,
  ) {
    if (lastIndex == childCount - 1)
      return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    //算出平均值
    final double averageExtent = (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    //加上剩余估计值
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }
```

#### Sliver绘制

[RenderSliverMultiBoxAdaptor](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_multi_box_adaptor.dart#L186)

* [paint方法](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_multi_box_adaptor.dart#L591)

``` dart
  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null)
      return;
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    Offset mainAxisUnit, crossAxisUnit, originOffset;
    bool addExtent;
    // 根据滚动的方向，来获取主轴和横轴的系数
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry.paintExtent, 0.0);
        addExtent = true;
        break;
    }
    assert(mainAxisUnit != null);
    assert(addExtent != null);
    RenderBox child = firstChild;
    while (child != null) {
      //获取child主轴的位置，为child的layoutOffset减去滚动位移scrollOffset
      final double mainAxisDelta = childMainAxisPosition(child);
      //获取child横轴的位置，ListView为0.0， GridView为计算出来的crossAxisOffset
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx + mainAxisUnit.dx * mainAxisDelta + crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy + mainAxisUnit.dy * mainAxisDelta + crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent)
        childOffset += mainAxisUnit * paintExtentOf(child);

     
      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      // 这里可以看到因为有cache的原因，有一些child其实是不需要绘制在我们可以看到的可视区域的
      if (mainAxisDelta < constraints.remainingPaintExtent && mainAxisDelta + paintExtentOf(child) > 0)
        context.paintChild(child, childOffset);

      child = childAfter(child);
    }
  }

```
### [RenderSliverFixedExtentList](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_fixed_extent_list.dart#L344)

当ListView的itemExtent不为null的时候，使用的是RenderSliverFixedExtentList。这个我们也只简单讲一下，由于知道了child主轴的高度，再各种计算当中就更加简单。我们可以根据scrollOffset和viewport直接算出来第一个child和最后一个child。

## [GridView](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scroll_view.dart#L1413)

### [RenderSliverGrid](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_grid.dart#L474)

最后是我们的GridView，因为GridView的设计为child的主轴大小和横轴大小/横轴child个数相等(当然还跟childAspectRatio(默认为1.0)宽高比例有关系)，所以说其实child主轴的大小也是已知的,而[横轴的绘制位置](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_grid.dart#L215)也很好定.基本上的计算原理也跟ListView差不多了。

## 举一反三

讲了一堆源码，不知道有多少人能看到这里。我们通过对源码分析，知道了sliver列表的一些计算绘制知识。接下来我们将对官方的Sliver 列表做一些扩展，来满足羞羞的效果。

### 图片列表内存优化

经常听到有小伙伴说图片列表滚动几下就闪退，这种情况在ios上面特别明显，而在安卓上面内存增长的很快，其原因是Flutter默认为图片做了内存缓存。就是说你如果滚动列表加载了300张图片，那么内存里面就会有300张图片的内存缓存，官方缓存上限为1000.

#### 列表内存测试

![](https://user-gold-cdn.xitu.io/2019/12/2/16ec75079384d11d?w=450&h=800&f=gif&s=4954496)

首先，我们来看看不做任何处理的情况下，图片列表的内存。我在这里做了一个图片列表，常见的9宫格的图片列表，增量加载child的总个数为300个，也就是说加载完毕之后可能有(1~9)*300=(300~2700)个图片内存缓存，当然因为官方缓存为1000，最终图片内存缓存应该在300到1000之间(如果总的图片大小没有超过官方的限制)。

#### 内存检测工具

* 首先，执行 `flutter packages pub global activate devtools` 激活 dart devtools
![](https://user-gold-cdn.xitu.io/2019/12/8/16ee338fd43815ac?w=672&h=308&f=png&s=41215)
* 激活成功之后，执行
`flutter --no-color packages pub global run devtools --machine --port=0` 
![](https://user-gold-cdn.xitu.io/2019/12/8/16ee33ab3eb01ae1?w=1038&h=189&f=png&s=56498) 将上图中的 127.0.0.1:9540 地址输入到浏览器中。

![](https://user-gold-cdn.xitu.io/2019/12/8/16ee33c3d47bfec8?w=1910&h=992&f=png&s=134392)
* 接下来我们需要执行 `flutter run --profile` 运行起来我们的测试应用
![](https://user-gold-cdn.xitu.io/2019/12/8/16ee3411eb47a460?w=1055&h=343&f=png&s=128720) 
执行完毕之后，会有一个地址，我们将这个地址copy到devtools中的Connect
![](https://user-gold-cdn.xitu.io/2019/12/8/16ee341dd140a580?w=880&h=245&f=png&s=21387)
* 点击Connect之后，在上部切换到Memory，我们就可以看到应用的实时内存变化监控了
![](https://user-gold-cdn.xitu.io/2019/12/8/16ee342ea1d419a6?w=1889&h=727&f=png&s=108961)

#### 不做任何处理的测试
* 安卓，我打开列表，一直向下拉，直到加载完毕300条，内存变化为下图，可以看到内存起飞爆炸
![](https://user-gold-cdn.xitu.io/2019/11/29/16eb5b3bcef5f6d8?w=1771&h=133&f=jpeg&s=35232)

![](https://user-gold-cdn.xitu.io/2019/11/29/16eb5b3d9ba19dee?w=1051&h=84&f=jpeg&s=21130)

* ios，我做了同样的步骤，可惜，它最终没有坚持到最后，600m左右闪退(跟ios应用内存限制有关)

上面例子很明显看到多图片列表对内存的巨大消耗，我们前面了解了Flutter中列表绘制整个流程，那么我们有没有办法来改进一下内存呢？ 答案是我们可以尝试在列表children回收的时候，我们主动去清除掉那个child中包含图片的内存缓存。这样内存中只有我们列表中少量的图片内存，另一方面由于我们图片做了硬盘缓存，即使我们清除了内存缓存，图片重新加载的时候也不会再次下载，对于用户来说无感知的。

#### 图片内存优化

我们前面提到过官方的[collectGarbage](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/sliver_multi_box_adaptor.dart#L514)方法，这个方法调用的时候将去清除掉不需要的children。那么我们可以在这个时刻将被清除children的indexes获取到并且通知用户。


[关键代码如下](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L130)。由于我不想重写更多的Sliver底层的类，所以我这里是通过[ExtendedListDelegate](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L20)中的回调将indexes传递出来。

``` dart
  void callCollectGarbage({
    CollectGarbage collectGarbage,
    int leadingGarbage,
    int trailingGarbage,
    int firstIndex,
    int targetLastIndex,
  }) {
    if (collectGarbage == null) return;

    List<int> garbages = [];
    firstIndex ??= indexOf(firstChild);
    targetLastIndex ??= indexOf(lastChild);
    for (var i = leadingGarbage; i > 0; i--) {
      garbages.add(firstIndex - i);
    }
    for (var i = 0; i < trailingGarbage; i++) {
      garbages.add(targetLastIndex + i);
    }
    if (garbages.length != 0) {
      //call collectGarbage
      collectGarbage.call(garbages);
    }
  }

```
当通知chilren被清除的时候，通过[ImageProvider.evict](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/image_provider.dart#L376)方法将图片缓存从内存中移除掉。
``` dart
    SliverListConfig<TuChongItem>(
      collectGarbage: (List<int> indexes) {
        ///collectGarbage
        indexes.forEach((index) {
           final item = listSourceRepository[index];
            if (item.hasImage) {
            item.images.forEach((image) {
              final provider = ExtendedNetworkImageProvider(
                image.imageUrl,
              );
              provider.evict();
            });
          }
            });
          },
```

经过优化之后执行同样的步骤，安卓内存变化为下
![](https://user-gold-cdn.xitu.io/2019/11/29/16eb5b3c998c5425?w=1636&h=139&f=jpeg&s=46080)

![](https://user-gold-cdn.xitu.io/2019/11/29/16eb5b3c2f4d4d1b?w=289&h=128&f=jpeg&s=13151)

ios也差不多，表现为下

![](https://user-gold-cdn.xitu.io/2019/11/29/16eb5c4100803ce5?w=1280&h=120&f=png&s=64706)

#### 不够极限？

从上面测试中，我们可以看到经过优化，图片列表的内存得到了大大的优化，基本满足我们的需求。但是我们做的还不够极限，因为对于列表图片来说，通常我们对它的图片质量其实不是那么高的(我又想起来了列表图片一张8m的那个大哥)

* 使用官方的ResizeImage，它是官方最近新加的，用于减少图片内存缓存。你可以通过设置width/height来减少图片，其实就是官方给你做了压缩。用法如下

当然这种用法的前提是你已经提前知道了图片的大小，这样你可以对图片进行等比压缩。比如下面代码我对宽高进行了5倍缩小。**注意的是，这样做了之后，图片的质量将会下降，如果太小了，就会糊掉。请根据自己的情况进行设置。另外一个问题是，列表图片和点击图片进行预览的图片，因为不是同一个ImageProvider了(预览图片一般都希望是高清的)，所以会重复下载，请根据自己的情况进行取舍。** 

[代码地址](https://github.com/fluttercandies/extended_image/blob/dev/example/lib/common/tu_chong_source.dart#L355)
``` dart
  ImageProvider createResizeImage() {
    return ResizeImage(ExtendedNetworkImageProvider(imageUrl),
        width: width ~/ 5, height: height ~/ 5);
  }
```
* 在继承[ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image_library/blob/master/lib/src/extended_network_image_provider.dart#L14)(当然extended的其他provider也通过这样方法来压缩图片), override instantiateImageCodec方法，这里对图片进行压缩。
[代码位置](https://github.com/fluttercandies/extended_image_library/blob/master/lib/src/extended_image_provider.dart#L13)

``` dart
  ///override this method, so that you can handle raw image data,
  ///for example, compress
  Future<ui.Codec> instantiateImageCodec(
      Uint8List data, DecoderCallback decode) async {
    _rawImageData = data;
    return await decode(data);
  }
```

* 在做了这些优化之后，我们再次进行测试，下面试内存变化情况，内存消耗再次被降低。
![](https://user-gold-cdn.xitu.io/2019/12/6/16ed8e88c28d3020?w=1794&h=139&f=jpeg&s=48355)

#### 支持我的PR

如果方案对你有用，请支持一下我对collectGarbage的PR.

[add collectGarbage method for SliverChildDelegate to track which children can be garbage collected ](https://github.com/flutter/flutter/pull/46357)

这样可以让更多人解决掉图片列表内存的问题。当然你也可以直接使用 [ExtendedList](https://github.com/fluttercandies/extended_list)          [WaterfallFlow](https://github.com/fluttercandies/waterfall_flow) 和  [LoadingMoreList](https://github.com/fluttercandies/loading_more_list) 它们都支持这个api。整个完整的解决方案我已经提交到了[ExtendedImage](https://github.com/fluttercandies/extended_image)的[demo](https://github.com/fluttercandies/extended_image/blob/dev/example/lib/pages/photo_view_demo.dart#L89)当中,方便查看整个流程。

### 列表曝光追踪

简单的说，就是我们怎么方便地知道在可视区域中的children呢？从列表的计算绘制过程中，其实我们是能够轻易获取到可视区域中children的indexes的。我这里提供了ViewportBuilder回调来获取可视区域中第一个index和最后一个index。
[代码位置](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L75)

同样是通过[ExtendedListDelegate](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L20)，在viewportBuilder中回调。

使用演示

``` dart
        ExtendedListView.builder(
            extendedListDelegate: ExtendedListDelegate(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```
### 特殊化最后一个child的布局

我们在入门Flutter的时候，做增量加载列表的时候，看到的例子就是把最后一个child作为loadmore/no more。ListView如果满屏幕的时候没有什么问题，但是下面情况需要解决。

* ListView未满屏的时候，最后一个child展示 ‘没有更多’。 通常是希望‘没有更多’ 是放在最下面进行显示，但是因为它是最后一个child，它会紧挨着倒数第2个。
* GridView 最后一个child作为loadmore/no more的时候。产品不希望它们当作普通的GridView元素来进行布局

为了解决这个问题，我设计了lastChildLayoutTypeBuilder。通过用户告诉的最后一个child的类型，来布局最后一个child，下面以RenderSliverList为例子。
``` dart
    if (reachedEnd) {
      ///zmt
      final layoutType = extendedListDelegate?.lastChildLayoutTypeBuilder
              ?.call(indexOf(lastChild)) ??
          LastChildLayoutType.none;
      // 最后一个child的大小
      final size = paintExtentOf(lastChild);
      // 最后一个child 绘制的结束位置
      final trailingLayoutOffset = childScrollOffset(lastChild) + size;
      //如果最后一个child绘制的结束位置小于了剩余绘制大小，那么我们将最后一个child的位置改为constraints.remainingPaintExtent - size
      if (layoutType == LastChildLayoutType.foot &&
          trailingLayoutOffset < constraints.remainingPaintExtent) {
        final SliverMultiBoxAdaptorParentData childParentData =
            lastChild.parentData;
        childParentData.layoutOffset = constraints.remainingPaintExtent - size;
        endScrollOffset = constraints.remainingPaintExtent;
      }
      estimatedMaxScrollOffset = endScrollOffset;
    }
```
最后我们看看怎么使用。

```dart
        enum LastChildLayoutType {
        /// 普通的
        none,

        /// 将最后一个元素绘制在最大主轴Item之后，并且使用横轴大小最为layout size
        /// 主要使用在[ExtendedGridView] and [WaterfallFlow]中，最后一个元素作为loadmore/no more元素的时候。
        fullCrossAxisExtend,

        /// 将最后一个child绘制在trailing of viewport，并且使用横轴大小最为layout size
        /// 这种常用于最后一个元素作为loadmore/no more元素，并且列表元素没有充满整个viewport的时候
        /// 如果列表元素充满viewport，那么效果跟fullCrossAxisExtend一样
        foot,
        }

      ExtendedListView.builder(
        extendedListDelegate: ExtendedListDelegate(
            // 列表的总长度应该是 length + 1
            lastChildLayoutTypeBuilder: (index) => index == length
                ? LastChildLayoutType.foot
                : LastChildLayoutType.none,
            ),
```

### 简单的聊天列表

我们在做一个聊天列表的时候，因为布局是从上向下的，我们第一反应肯定是将
ListView的reverse设置为true，当有新的会话会被插入0的位置，这样设置是最简单，但是当会话没有充满viewport的时候，因为布局被翻转，所以布局会像下面这样。

```
     trailing
-----------------
|               |
|               |
|     item2     |
|     item1     |
|     item0     |
-----------------
     leading
```     

为了解决这个问题，你可以设置 closeToTrailing 为true, 布局将变成如下
该属性同时支持[ExtendedGridView],[ExtendedList],[WaterfallFlow]。
当然如果reverse如果不为ture，你设置这个属性依然会生效，没满viewport的时候布局会紧靠trailing。

```
     trailing
-----------------
|     item2     |
|     item1     |
|     item0     |
|               |
|               |
-----------------
     leading
```     

那是如何是现实的呢？为此我增加了2个扩展方法

* [handleCloseToTrailingEnd](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L155)

如果最后一个child的绘制结束位置没有剩余绘制区域大(也就是children未填充满viewport)，那么我们给每一个child的绘制起点增加constraints.remainingPaintExtent - endScrollOffset的距离，那么现象就会是全部children是紧靠trailing布局的。这个方法为整体计算布局之后调用。

``` dart
  /// handle closeToTrailing at end
  double handleCloseToTrailingEnd(
      bool closeToTrailing, double endScrollOffset) {
    if (closeToTrailing && endScrollOffset < constraints.remainingPaintExtent) {
      RenderBox child = firstChild;
      final distance = constraints.remainingPaintExtent - endScrollOffset;
      while (child != null) {
        final SliverMultiBoxAdaptorParentData childParentData =
            child.parentData;
        childParentData.layoutOffset += distance;
        child = childAfter(child);
      }
      return constraints.remainingPaintExtent;
    }
    return endScrollOffset;
  }
```
* [handleCloseToTrailingBegin](https://github.com/fluttercandies/extended_list_library/blob/master/lib/src/extended_list_library.dart#L156)

因为我们给每个child的绘制起点增加了constraints.remainingPaintExtent - endScrollOffset的距离。再下一次performLayout的时候，我们应该先移除掉这部分的距离。当第一个child的index为0 并且layoutOffset不为0，我们需要将全部的children的layoutOffset做移除。

``` dart
  /// handle closeToTrailing at begin
  void handleCloseToTrailingBegin(bool closeToTrailing) {
    if (closeToTrailing) {
      RenderBox child = firstChild;
      SliverMultiBoxAdaptorParentData childParentData = child.parentData;
      // 全部移除掉前一次performLayout增加的距离
      if (childParentData.index == 0 && childParentData.layoutOffset != 0) {
        var distance = childParentData.layoutOffset;
        while (child != null) {
          childParentData = child.parentData;
          childParentData.layoutOffset -= distance;
          child = childAfter(child);
        }
      }
    }
  }
```

最后我们看看怎么使用。

```dart
      ExtendedListView.builder(
        reverse: true,
        extendedListDelegate: ExtendedListDelegate(closeToTrailing: true),
```

## 结语

这一章我们通过对sliver 列表的源码进行分析，举一反四，解决了实际开发中的一些问题。下一章我们将创造自己的瀑布流布局，你也能有创建任意sliver布局列表的能力。

欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果[![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)
