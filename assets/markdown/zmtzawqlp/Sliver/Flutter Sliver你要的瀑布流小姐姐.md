![](https://user-gold-cdn.xitu.io/2019/10/18/16ddcea08cf56d0f?w=392&h=145&f=png&s=14253)
## 前言

今天看了Flutter Interact, 全程有个小姐姐翻译（同声翻译，好强力），于是我就边听边完成了这篇文章。
![](https://user-gold-cdn.xitu.io/2019/12/11/16ef58eaf6e4dfe8?w=1158&h=550&f=jpeg&s=33175)

接着上一章[Flutter Sliver一生之敌 (ExtendedList)](https://juejin.im/post/6844904015994552333)，这章我们将编写一个瀑布流布局，来检验一下我们上一章对Sliver列表源码分析是否正确。

欢迎加入Flutter Candies [![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

* [ Flutter Sliver一生之敌 (ScrollView)](https://juejin.im/post/6844904008339947528)
* [Flutter Sliver一生之敌 (ExtendedList)](https://juejin.im/post/6844904015994552333)
* [Flutter Sliver你要的瀑布流小姐姐](https://juejin.im/post/6844904018804752391)
* [Flutter Sliver 锁住你的美](https://juejin.im/post/6861798947208953863)

![](https://user-gold-cdn.xitu.io/2019/12/9/16eea8091cca6b28?w=300&h=300&f=png&s=44572)
知道你们只关心小姐姐，我还是先放效果图吧。

|![](https://user-gold-cdn.xitu.io/2019/12/9/16eea85f2f8c30c6?w=450&h=800&f=gif&s=1864924) |![](https://user-gold-cdn.xitu.io/2019/12/9/16eea865eb34f53f?w=450&h=800&f=gif&s=1150195) |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| ![](https://user-gold-cdn.xitu.io/2019/12/9/16eea870f07d81bd?w=450&h=800&f=gif&s=5115847)  | ![](https://user-gold-cdn.xitu.io/2019/12/9/16eea87c8c0102b9?w=360&h=640&f=gif&s=4800819)|

## 原理

之前做UWP的时候，我自己也做过瀑布流布局。似乎是一种执念，入坑Flutter之后也想实现一下瀑布流布局。下面简单讲一下什么是瀑布流以及原理。

瀑布流布局的特点是等宽不等高。
为了让最后一行的差距最小，从第二行开始，需要将一项放在第一行最矮的一项下面，以此类推，如下图。4在0下面，5在3下面，6在1下面，7在2下面，8在4下面...

![](https://user-gold-cdn.xitu.io/2019/12/9/16eea9ff1969c2c2?w=1080&h=1920&f=png&s=46701)


## 核心代码

知道了原理，下面我们来一起把原理实现为代码。

* 由于我们需要知道离viewport顶部最近的Items，以及viewport底部最近的Items。这样才能知道向后滚动新的item放哪个item下面，或者说向前滚动的时候知道新的item放在哪个item的上面
我设计了[CrossAxisItems](https://github.com/zmtzawqlp/waterfall_flow/blob/master/lib/src/rendering/sliver_waterfall_flow.dart#L469) 来存放leadingItems 和 trailingItems。

* 向后添加新的item的时候代码如下

1.补充leadingItems直到等于crossAxisCount

2.找到当前最矮的一项，将设置它的layoutoffset

3.保存这一列的indexes
``` dart
  void insert({
    @required RenderBox child,
    @required ChildTrailingLayoutOffset childTrailingLayoutOffset,
    @required PaintExtentOf paintExtentOf,
  }) {
    final WaterfallFlowParentData data = child.parentData;
    final LastChildLayoutType lastChildLayoutType =
        delegate.getLastChildLayoutType(data.index);
    
    ///处理最后一个特殊化布局
    switch (lastChildLayoutType) {
      case LastChildLayoutType.fullCrossAxisExtend:
      case LastChildLayoutType.foot:
        //横轴绘制offset
        data.crossAxisOffset = 0.0;
        //横轴index
        data.crossAxisIndex = 0;
        //该child的大小
        final size = paintExtentOf(child);
        
        if (lastChildLayoutType == LastChildLayoutType.fullCrossAxisExtend ||
            maxChildTrailingLayoutOffset + size >
                constraints.remainingPaintExtent) {
          data.layoutOffset = maxChildTrailingLayoutOffset;
        } else {
          //如果全部children没有绘制viewport的大
          data.layoutOffset = constraints.remainingPaintExtent - size;
        }
        data.trailingLayoutOffset = childTrailingLayoutOffset(child);
        return;
      case LastChildLayoutType.none:
        break;
    }

    if (!leadingItems.contains(data)) {
      //补充满leadingItems
      if (leadingItems.length != crossAxisCount) {
        data.crossAxisIndex ??= leadingItems.length;

        data.crossAxisOffset =
            delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

        if (data.index < crossAxisCount) {
          data.layoutOffset = 0.0;
          data.indexs.clear();
        }

        trailingItems.add(data);
        leadingItems.add(data);
      } else {
        if (data.crossAxisIndex != null) {
          var item = trailingItems.firstWhere(
              (x) =>
                  x.index > data.index &&
                  x.crossAxisIndex == data.crossAxisIndex,
              orElse: () => null);

          ///out of viewport
          if (item != null) {
            data.trailingLayoutOffset = childTrailingLayoutOffset(child);
            return;
          }
        }
        //找到最矮的那个
        var min = trailingItems.reduce((curr, next) =>
            ((curr.trailingLayoutOffset < next.trailingLayoutOffset) ||
                    (curr.trailingLayoutOffset == next.trailingLayoutOffset &&
                        curr.crossAxisIndex < next.crossAxisIndex)
                ? curr
                : next));

        data.layoutOffset = min.trailingLayoutOffset + delegate.mainAxisSpacing;
        data.crossAxisIndex = min.crossAxisIndex;
        data.crossAxisOffset =
            delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

        trailingItems.forEach((f) => f.indexs.remove(min.index));
        min.indexs.add(min.index);
        data.indexs = min.indexs;
        trailingItems.remove(min);
        trailingItems.add(data);
      }
    }

    data.trailingLayoutOffset = childTrailingLayoutOffset(child);
  }
```
* 向前添加新的item的时候代码如下

1.通过indexs找到新item属于哪一列

2.添加到旧的item的上面
``` dart
  void insertLeading({
    @required RenderBox child,
    @required PaintExtentOf paintExtentOf,
  }) {
    final WaterfallFlowParentData data = child.parentData;
    if (!leadingItems.contains(data)) {
      var pre = leadingItems.firstWhere((x) => x.indexs.contains(data.index),
          orElse: () => null);

      if (pre == null || pre.index < data.index) return;

      data.trailingLayoutOffset = pre.layoutOffset - delegate.mainAxisSpacing;
      data.crossAxisIndex = pre.crossAxisIndex;
      data.crossAxisOffset =
          delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

      leadingItems.remove(pre);
      leadingItems.add(data);
      trailingItems.remove(pre);
      trailingItems.add(data);
      data.indexs = pre.indexs;

      data.layoutOffset = data.trailingLayoutOffset - paintExtentOf(child);
    }
  }
```
* 计算离viewport顶部最近的，应该确保leadingItems都在viewport里面
跟之前Listview的源码分析差不多，只是这里我们要保证最大的LeadingLayoutOffset都小于scrollOffset，这样leadingItems就都在viewport里面了
``` dart
    if (crossAxisItems.maxLeadingLayoutOffset > scrollOffset) {
      RenderBox child = firstChild;
      //move to max index of leading
      final int maxLeadingIndex = crossAxisItems.maxLeadingIndex;
      while (child != null && maxLeadingIndex > indexOf(child)) {
        child = childAfter(child);
      }
      //fill leadings from max index of leading to min index of leading
      while (child != null && crossAxisItems.minLeadingIndex < indexOf(child)) {
        crossAxisItems.insertLeading(
            child: child, paintExtentOf: paintExtentOf);
        child = childBefore(child);
      }
      //collectGarbage(maxLeadingIndex - index, 0);

      while (crossAxisItems.maxLeadingLayoutOffset > scrollOffset) {
        // We have to add children before the earliestUsefulChild.
        earliestUsefulChild =
            insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

        if (earliestUsefulChild == null) {
          if (scrollOffset == 0.0) {
            // insertAndLayoutLeadingChild only lays out the children before
            // firstChild. In this case, nothing has been laid out. We have
            // to lay out firstChild manually.
            firstChild.layout(childConstraints, parentUsesSize: true);

            earliestUsefulChild = firstChild;
            leadingChildWithLayout = earliestUsefulChild;
            trailingChildWithLayout ??= earliestUsefulChild;
            crossAxisItems.reset();
            crossAxisItems.insert(
              child: earliestUsefulChild,
              childTrailingLayoutOffset: childTrailingLayoutOffset,
              paintExtentOf: paintExtentOf,
            );
            break;
          } else {
            // We ran out of children before reaching the scroll offset.
            // We must inform our parent that this sliver cannot fulfill
            // its contract and that we need a scroll offset correction.
            geometry = SliverGeometry(
              scrollOffsetCorrection: -scrollOffset,
            );
            return;
          }
        }

        crossAxisItems.insertLeading(
            child: earliestUsefulChild, paintExtentOf: paintExtentOf);

        final WaterfallFlowParentData data = earliestUsefulChild.parentData;

        // firstChildScrollOffset may contain double precision error
        if (data.layoutOffset < -precisionErrorTolerance) {
          // The first child doesn't fit within the viewport (underflow) and
          // there may be additional children above it. Find the real first child
          // and then correct the scroll position so that there's room for all and
          // so that the trailing edge of the original firstChild appears where it
          // was before the scroll offset correction.
          // do this work incrementally, instead of all at once,
          // i.e. find a way to avoid visiting ALL of the children whose offset
          // is < 0 before returning for the scroll correction.
          double correction = 0.0;
          while (earliestUsefulChild != null) {
            assert(firstChild == earliestUsefulChild);
            correction += paintExtentOf(firstChild);
            earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
                parentUsesSize: true);
            crossAxisItems.insertLeading(
                child: earliestUsefulChild, paintExtentOf: paintExtentOf);
          }
          geometry = SliverGeometry(
            scrollOffsetCorrection: correction - data.layoutOffset,
          );
          return;
        }

        assert(earliestUsefulChild == firstChild);
        leadingChildWithLayout = earliestUsefulChild;
        trailingChildWithLayout ??= earliestUsefulChild;
      }
    }
```

* 计算达到viewport底部，应该确保trailingItems中最短的要超过viewport的底部
``` dart
    // Now find the first child that ends after our end.
    if (child != null) {
      while (crossAxisItems.minChildTrailingLayoutOffset <
              targetEndScrollOffset ||
              //make sure leading children are painted. 
          crossAxisItems.leadingItems.length < _gridDelegate.crossAxisCount
          || crossAxisItems.leadingItems.length  > childCount
          ) {
        if (!advance()) {
          reachedEnd = true;
          break;
        }
      }
    }
```

## [waterfall_flow](https://github.com/fluttercandies/waterfall_flow)使用

* 在pubspec.yaml中增加库引用
  
```yaml

dependencies:
  waterfall_flow: any

```  
* 导入库
  
```dart

  import 'package:waterfall_flow/waterfall_flow.dart';
  
```
## 如何定义

你可以通过设置SliverWaterfallFlowDelegate参数来定义瀑布流

| 参数                       | 描述                                   | 默认  |
| -------------------------- | -------------------------------------- | ----- |
| crossAxisCount             | 横轴的等长度元素数量                   | 必填  |
| mainAxisSpacing            | 主轴元素之间的距离                     | 0.0   |
| crossAxisSpacing           | 横轴元素之间的距离                     | 0.0   |
| collectGarbage             | 元素回收时候的回调                     | -     |
| lastChildLayoutTypeBuilder | 最后一个元素的布局样式(详情请查看后面) | -     |
| viewportBuilder            | 可视区域中元素indexes变化时的回调      | -     |
| closeToTrailing            | 可否让布局紧贴trailing(详情请查看后面) | false |

```dart
            WaterfallFlow.builder(
              //cacheExtent: 0.0,
              padding: EdgeInsets.all(5.0),
              gridDelegate: SliverWaterfallFlowDelegate(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  /// follow max child trailing layout offset and layout with full cross axis extend
                  /// last child as loadmore item/no more item in [GridView] and [WaterfallFlow]
                  /// with full cross axis extend
                  //  LastChildLayoutType.fullCrossAxisExtend,

                  /// as foot at trailing and layout with full cross axis extend
                  /// show no more item at trailing when children are not full of viewport
                  /// if children is full of viewport, it's the same as fullCrossAxisExtend
                  //  LastChildLayoutType.foot,
                  lastChildLayoutTypeBuilder: (index) => index == _list.length
                      ? LastChildLayoutType.foot
                      : LastChildLayoutType.none,
                  ),

```
[完整小姐姐Demo](https://github.com/fluttercandies/waterfall_flow/blob/master/example/lib/pages/known_sized_demo.dart)

## 结语

没有再对源码有更多的分析，上一篇如果你看过了，应该会更加明白其中的道理。这一篇是对瀑布流原理在Flutter上面实现的展示，没有做不到效果，只有想不到的效果，这就是Flutter给我带来的体验。

最后放上Flutter Interact 的一些内容，我是边听边写的，如果有误，请提醒我更改下。

* Flutter 1.12版本
* Material design 以及字体库
* 带来了Desktop/Web(你现在可以尝试他们了,不再是玩具)
* 叼炸天的各种开发工具(同时调试7种设备，UI化界面)
* [gskinner](https://flutter.gskinner.com/) 酷炫交互+开源
* [supernova](https://blog.prototypr.io/sketch-to-flutter-automatically-cf693ea1c892) 知名的 design-to-code (设计转代码) 工具
* [Adobe XD](https://github.com/thize/xd-to-flutter) 程序猿们颤抖吧，UI将代替你们了。
* [flutter_vignettes](https://github.com/gskinnerTeam/flutter_vignettes/tree/master/vignettes/gooey_edge)商业互吹
* [rive.app](https://rive.app/)展示了一个炒鸡可爱的游戏，而且是用Flutter web


欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果[![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)


