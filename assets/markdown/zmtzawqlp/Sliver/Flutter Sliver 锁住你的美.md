![](https://user-gold-cdn.xitu.io/2019/10/18/16ddcea08cf56d0f?w=392&h=145&f=png&s=14253)

* [ Flutter Sliver一生之敌 (ScrollView)](https://juejin.im/post/6844904008339947528)
* [Flutter Sliver一生之敌 (ExtendedList)](https://juejin.im/post/6844904015994552333)
* [Flutter Sliver你要的瀑布流小姐姐](https://juejin.im/post/6844904018804752391)
* [Flutter Sliver 锁住你的美](https://juejin.im/post/6861798947208953863)
## 前言

离上一篇Sliver相关文章 [Flutter Sliver 你要的瀑布流小姐姐](https://juejin.im/post/6844904018804752391) 居然有8个月了，写bug真费时间。Sliver虽然说肥肠好用，但是还是有那么一些小缺陷。

* SliverPersistentHeader

使用过这个的人，应该都会碰到一个问题，那就是为啥必须要设置 `minExtent` 和 `maxExtent` ？ 如果Widget里面的高度我没法提前知道，比如里面是一段文字，不知道长短，没法提前知道高度(当然你可以用TextPainter)。这种情况真的是很恶心，反正我一年前写代码的时候只能靠提前计算，low。

* SliverToBoxAdapter

我想在CustomScrollView里面pinned一个Widget，我想每个人的第一反应是使用SliverPersistentHeader，然后 minExtent 和 maxExtent 设置成相同的。那么问题问题一样，我没法提前知道Widget的高度怎么办？

* SliverAppbar

里面是用 SliverPersistentHeader 制作的，暴露出来一个expandedHeight。又来了，你又要我提前设置高度。

## 怎么样才能优美地锁住你呢

老规矩，第一步看源码。

### SliverPinnedPersistentHeader

#### 看源码 SliverPersistentHeader 

这里官方根据 `pinned` 和 `floating` 的不同，分为下面4种情况。

``` dart
    if (floating && pinned)
      return _SliverFloatingPinnedPersistentHeader(delegate: delegate);
    if (pinned)
      return _SliverPinnedPersistentHeader(delegate: delegate);
    if (floating)
      return _SliverFloatingPersistentHeader(delegate: delegate);
    return _SliverScrollingPersistentHeader(delegate: delegate);
```

我这里默认你们看过之前的文章了，我就直接到最终影响布局的地方了，具体到影响布局的地方分为

* `RenderSliverScrollingPersistentHeader extends RenderSliverPersistentHeader`
* `RenderSliverPinnedPersistentHeader extends RenderSliverPersistentHeader `
* `RenderSliverFloatingPersistentHeader extends RenderSliverPersistentHeader`
* `RenderSliverFloatingPinnedPersistentHeader extends RenderSliverFloatingPersistentHeader `

可以看到的是最终它们都继承 `RenderSliverPersistentHeader`，会有相同的paint 过程，而他们的不同主要在于 `performLayout` 和 `childMainAxisPosition` 2个方法。

我们这里只关注一下`pinned:true`的情况。

`RenderSliverPinnedPersistentHeader` 我这里只留下关键的代码。
``` dart
  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // delegate 的 maxExtent
    final double maxExtent = this.maxExtent;
    // 是否与其他Sliver重叠
    final bool overlapsContent = constraints.overlap > 0.0;
    // layoutChild 这里会调用 delegate.build方法
    layoutChild(constraints.scrollOffset, maxExtent, overlapsContent: overlapsContent);
    // 剩余绘制区域
    final double effectiveRemainingPaintExtent = math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    // layout区域
    final double layoutExtent = (maxExtent - constraints.scrollOffset).clamp(0.0, effectiveRemainingPaintExtent) as double;
    final double stretchOffset = stretchConfiguration != null ?
      constraints.overlap.abs() :
      0.0;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent + stretchOffset,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0 ? -constraints.cacheOrigin + layoutExtent : layoutExtent,
      hasVisualOverflow: true, // Conservatively say we do have overflow to avoid complexity.
    );
  }
  
  // 会影响paint方法中最终child绘制位置。
  @override
  double childMainAxisPosition(RenderBox child) => 0.0;
```

上面的东西应该比较熟悉了，Sliver系列里面必考知识。其实我们这里只需要想办法，将 `minExtent` 和 `maxExtent` 在 `performLayout` 的过程中计算出来就好了。

### 怎么通过 Widget 计算出 `minExtent` 和 `maxExtent` 呢

#### 将 Widget 转换成 RenderBox

我们都知道 Widget <=> Element <=> RenderOjbect ，Element 在 `mount` 中讲自己跟 `parent` 关联，这个时候我们就可以通过 `updateChild` 方法将 Widget转换成对应的 `Element`， 并且在 `insertChildRenderObject` 获取到 Widget 对应的 RenderOjbect(RenderBox).

[重要代码](https://github.com/fluttercandies/extended_sliver/blob/master/lib/src/element.dart#L28)如下:

``` dart
  Element _minExtentPrototype;
  static final Object _minExtentPrototypeSlot = Object();
  Element _maxExtentPrototype;
  static final Object _maxExtentPrototypeSlot = Object();

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    renderObject.element = this;
    _minExtentPrototype = updateChild(_minExtentPrototype,
        // minExtent对应的Widget
        widget.delegate.minExtentProtoType, _minExtentPrototypeSlot);
    _maxExtentPrototype = updateChild(_maxExtentPrototype,
        // maxExtent对应的Widget
        widget.delegate.maxExtentProtoType, _maxExtentPrototypeSlot);
  }
  
  @override
  void insertChildRenderObject(covariant RenderBox child, dynamic slot) {
    assert(renderObject.debugValidateChild(child));

    assert(child is RenderBox);
    // 根据 slot 给 RenderOject 赋值对应的 child
    if (slot == _minExtentPrototypeSlot) {
      renderObject.minProtoType = child;
    } else if (slot == _maxExtentPrototypeSlot) {
      renderObject.maxProtoType = child;
    } else {
      renderObject.child = child;
    }
  }  
```

其堆栈信息如下图
![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/72a3a06096bc46c8be88e8e1d1d792d7~tplv-k3u1fbpfcp-zoom-1.image)

#### 通过 RenderBox.layout 计算 `minExtent` 和 `maxExtent`

这部分就相对简单了，[代码如下](https://github.com/fluttercandies/extended_sliver/blob/master/lib/src/render.dart#L53)：
逻辑跟官方没有区别，只是 `minExtent` 和 `maxExtent` 是通过 `minProtoType` 和 `maxProtoType` 计算而来

``` dart

  RenderBox _minProtoType;
  RenderBox get minProtoType => _minProtoType;
  set minProtoType(RenderBox value) {
    if (_minProtoType != null) {
      dropChild(_minProtoType);
    }
    _minProtoType = value;
    if (_minProtoType != null) {
      adoptChild(_minProtoType);
    }
    markNeedsLayout();
  }

  RenderBox _maxProtoType;
  RenderBox get maxProtoType => _maxProtoType;
  set maxProtoType(RenderBox value) {
    if (_maxProtoType != null) {
      dropChild(_maxProtoType);
    }
    _maxProtoType = value;
    if (_maxProtoType != null) {
      adoptChild(_maxProtoType);
    }
    markNeedsLayout();
  }

  double get minExtent => getChildExtend(minProtoType, constraints);
  double get maxExtent => getChildExtend(maxProtoType, constraints);

double getChildExtend(RenderBox child, SliverConstraints constraints) {
  if (child == null) {
    return 0.0;
  }
  assert(child.hasSize);
  assert(constraints.axis != null);
  switch (constraints.axis) {
    case Axis.vertical:
      return child.size.height;
    case Axis.horizontal:
      return child.size.width;
  }
  return null;
}

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    minProtoType.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    maxProtoType.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final bool overlapsContent = constraints.overlap > 0.0;
    excludeFromSemanticsScrolling =
        overlapsContent || (constraints.scrollOffset > maxExtent - minExtent);
    layoutChild(constraints.scrollOffset, maxExtent,
        overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (maxExtent - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent) as double;

    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
  }
```

### SliverPinnedToBoxAdapter

#### 看源码 SliverToBoxAdapter 

SliverToBoxAdapter 的源码相对简单，它是通过 `ParentData` 设置绘制开始点，在 `paint` 方法中进行绘制的

``` dart
class RenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverToBoxAdapter({
    RenderBox child,
  }) : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child.size.width;
        break;
      case Axis.vertical:
        childExtent = child.size.height;
        break;
    }
    assert(childExtent != null);
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child, constraints, geometry);
  }
}
```

其实我们开始说过，一个 `pinned: true` 的 SliverToBoxAdapter， 其实可以转换成为 `SliverPersistentHeader(pinned: true)` 并且 `minExtent` = ` maxExtent` = child 的 extent。那么一切都好解决了，我们可以把 `RenderSliverPinnedPersistentHeader` 中的 `performLayout` 代码直接拿过来用, 并且把计算好的绘制开始点赋值给 ParentData 即可。

``` dart
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    assert(childExtent != null);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (childExtent - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent) as double;

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: childExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
    setChildParentData(child, constraints, geometry);
  }

  @override
  void setChildParentData(RenderObject child, SliverConstraints constraints,
      SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData =
        child.parentData as SliverPhysicalParentData;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);
    Offset offset = Offset.zero;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        offset += Offset(
            0.0,
            geometry.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent);
        break;
      case AxisDirection.down:
        offset += Offset(0.0, childMainAxisPosition(child as RenderBox));
        break;
      case AxisDirection.left:
        offset += Offset(
            geometry.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent,
            0.0);
        break;
      case AxisDirection.right:
        offset += Offset(childMainAxisPosition(child as RenderBox), 0.0);
        break;
    }
    childParentData.paintOffset = offset;
    assert(childParentData.paintOffset != null);
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;
```

### ExtendedSliverAppbar

这个就不带看代码了，蛮简单的，里面是用 SliverPinnedPersistentHeader` 做的， 当然也是参考了官方的 `SliverAppbar`， 只是没有官方那么复杂，相信看过我前面几篇Sliver相关文章的人，都可以随便魔改。

## 怎么使用Sliver扩展库

### 添加引用

添加引用到 `pubspec.yaml` 下面的 `dependencies`

```yaml
dependencies:
  extended_sliver: latest-version
```

执行 `flutter packages get` 下载

### SliverPinnedPersistentHeader

跟官方的`SliverPersistentHeader(pinned: true)`一样, 不同的是你不需要去设置 minExtent 和 maxExtent。

它是通过设置 `minExtentProtoType` 和 `maxExtentProtoType` 来计算 minExtent 和 maxExtent。

当Widget没有layout之前，你没法知道Widget的实际大小，这将是非常有用的组件。

```dart
    SliverPinnedPersistentHeader(
      delegate: MySliverPinnedPersistentHeaderDelegate(
        minExtentProtoType: Container(
          height: 120.0,
          color: Colors.red.withOpacity(0.5),
          child: FlatButton(
            child: const Text('minProtoType'),
            onPressed: () {
              print('minProtoType');
            },
          ),
          alignment: Alignment.topCenter,
        ),
        maxExtentProtoType: Container(
          height: 200.0,
          color: Colors.blue,
          child: FlatButton(
            child: const Text('maxProtoType'),
            onPressed: () {
              print('maxProtoType');
            },
          ),
          alignment: Alignment.bottomCenter,
        ),
      ),
    )
```
### SliverPinnedToBoxAdapter

你可以轻松创建一个锁定的Sliver。

当child没有layout之前，你没法知道child的实际大小，这将是非常有用的组件。

```dart
    SliverPinnedToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.blue.withOpacity(0.5),
        child: Column(
          children: <Widget>[
            const Text(
                '[love]Extended text help you to build rich text quickly. any special text you will have with extended text. '
                '\n\nIt\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love]'
                '\n\nif you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]'),
            FlatButton(
              child: const Text('I\'m button. click me!'),
              onPressed: () {
                debugPrint('click');
              },
            ),
          ],
        ),
      ),
    )
```
### ExtendedSliverAppbar

你可以创建一个SliverAppbar，不用去设置expandedHeight。

```dart
return CustomScrollView(
  slivers: <Widget>[
    ExtendedSliverAppbar(
      title: const Text(
        'ExtendedSliverAppbar',
        style: TextStyle(color: Colors.white),
      ),
      leading: const BackButton(
        onPressed: null,
        color: Colors.white,
      ),
      background: Image.asset(
        'assets/cypridina.jpeg',
        fit: BoxFit.cover,
      ),
      actions: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
      ),
    ),
  ],
);
```

## 复杂的例子

[例子地址](https://github.com/fluttercandies/extended_sliver/blob/master/example/lib/pages/complex/home_page.dart), 包括下面的功能。

* 文字随机长度，不用写死 maxExtent
* 下拉刷新
* 根据按钮的位置来控制Toolbar里面按钮的显隐

![image](http://zmtzawqlp.gitee.io/my_images/images/extended_sliver/extended_sliver.gif)


## 结语

2020年是一个忙碌的一年，也是Flutter快速发展的一年，web 的性能得到了提高，macos，linux 都已经 beta， uwp 也在路上。就差你了，看什么看，就是说你呢？！
放上[extended_sliver](https://github.com/fluttercandies/extended_sliver),如果你有什么好的Sliver效果，欢迎pr;如果你有什么新需求，欢迎氪金。

欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果[![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)
