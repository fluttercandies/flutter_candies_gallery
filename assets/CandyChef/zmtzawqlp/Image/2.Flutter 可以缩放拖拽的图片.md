[extended_image](https://github.com/fluttercandies/extended_image) 相关文章

- [Flutter 什么功能都有的Image](https://juejin.im/post/6844903794656952328)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/6844903814324027400)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/6844903860163575815)
- [Flutter 图片裁剪旋转翻转编辑器](https://juejin.im/post/6844903939670802446)

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image)
在pub上面找了下，没有发现一个效果跟微信一样的支持缩放拖拽效果的image，所以就自己撸了一个，之前写过[Flutter 什么功能都有的Image](https://juejin.im/post/6844903794656952328)，于是就在这个上面新增了这个功能。

主要功能：
- 缩放拖拽
- 在PageView里面缩放拖拽

## 支持缩放拖拽

![](https://user-gold-cdn.xitu.io/2019/4/6/169f33836ce15ba8?w=360&h=640&f=gif&s=4805057)
### 用法
1.将[extended_image](https://github.com/fluttercandies/extended_image)的mode参数设置为ExtendedImageMode.Gesture

2.设置GestureConfig
```dart
 ExtendedImage.network(
  imageTestUrl,
  fit: BoxFit.contain,
  //enableLoadState: false,
  mode: ExtendedImageMode.Gesture,
  initGestureConfigHandler: (state) {
    return GestureConfig(
        minScale: 0.9,
        animationMinScale: 0.7,
        maxScale: 3.0,
        animationMaxScale: 3.5,
        speed: 1.0,
        inertialSpeed: 100.0,
        initialScale: 1.0,
        inPageView: false);
  },
)
```
GestureConfig 参数说明
| 参数 | 描述 | 默认值 |
| ------ | ------ | ------ |
| minScale | 缩放最小值 | 0.8 |
| animationMinScale | 缩放动画最小值，当缩放结束时回到minScale值 | minScale * 0.8 |
| maxScale | 缩放最大值 | 5.0 |
| animationMaxScale | 缩放动画最大值，当缩放结束时回到maxScale值 | maxScale * 1.2 |
| speed | 缩放拖拽速度，与用户操作成正比 | 1.0 |
| inertialSpeed | 拖拽惯性速度，与惯性速度成正比 | 100 |
| cacheGesture | 是否缓存手势状态，可用于Pageview中保留状态，使用clearGestureDetailsCache方法清除 | false |
| inPageView | 是否使用ExtendedImageGesturePageView展示图片 | false |


### 实现过程

这一个功能比较简单，参考了官方的[gestures demo](https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart)，将缩放的Scale和Offset转换了为了图片最后显示的区域，具体代码在最后绘制图片的时候，将gestureDetails转换为对应的图片显示区域。

![](https://user-gold-cdn.xitu.io/2019/4/5/169edc69a415a33d?w=329&h=185&f=png&s=11064)
```dart
 bool gestureClip = false;
  if (gestureDetails != null) {
    destinationRect =
        gestureDetails.calculateFinalDestinationRect(rect, destinationRect);

    ///outside and need clip
    gestureClip = outRect(rect, destinationRect);

    if (gestureClip) {
      canvas.save();
      canvas.clipRect(rect);
    }
  }
```

rect 是整个图片在屏幕上的区域，destinationRect图片显示区域(会根据BoxFit的不同而所不同)，通过gestureDetails的calculateFinalDestinationRect方式，计算出最终显示区域。

#### 让缩放的过程看起来流畅
1.根据缩放点相对图片的位置对缩放点作为中心点进行缩放

2.如果Scale小于等于1.0的时候，按照图片的中心点进行缩放的，而当大于1.0并且图片已经铺满区域的时候按照1来执行

3.当图片是那种长宽相差很大的时候，进行缩放的时候，将首先沿着比较长的那边进行中心点缩放，直到图片铺满区域之后，按照1来执行

4.当进行缩放操作的时候，不进行移动操作

1，2，3对应代码
```dart
Offset _getCenter(Rect destinationRect) {
    if (!userOffset && _center != null) {
      return _center;
    }

    if (totalScale > 1.0) {
      if (_computeHorizontalBoundary && _computeVerticalBoundary) {
        return destinationRect.center * totalScale + offset;
      } else if (_computeHorizontalBoundary) {
        //only scale Horizontal
        return Offset(destinationRect.center.dx * totalScale,
                destinationRect.center.dy) +
            Offset(offset.dx, 0.0);
      } else if (_computeVerticalBoundary) {
        //only scale Vertical
        return Offset(destinationRect.center.dx,
                destinationRect.center.dy * totalScale) +
            Offset(0.0, offset.dy);
      } else {
        return destinationRect.center;
      }
    } else {
      return destinationRect.center;
    }
  }
```

4对应代码,当details.scale==1.0，说明是一个移动操作，否则为了一个缩放操作
```dart
void _handleScaleUpdate(ScaleUpdateDetails details) {
    ...
    var offset =
        ((details.scale == 1.0 ? details.focalPoint : _startingOffset) -
            _normalizedOffset * scale);
    ...
  }
```

获取到了图片的中心点之后，我们再根据Scale等到图片的整个区域
```dart
 Rect _getDestinationRect(Rect destinationRect, Offset center) {
    final double width = destinationRect.width * totalScale;
    final double height = destinationRect.height * totalScale;

    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }
```
#### 拖拽边界的计算
1.计算是否需要计算限制边界
2.如果需要将区域限制在边界内部
``` dart
    if (_computeHorizontalBoundary) {
      //move right
      if (result.left >= layoutRect.left) {
        result = Rect.fromLTWH(0.0, result.top, result.width, result.height);
        _boundary.left = true;
      }

      ///move left
      if (result.right <= layoutRect.right) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);
        _boundary.right = true;
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom <= layoutRect.bottom) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);
        _boundary.bottom = true;
      }

      //move up
      if (result.top >= layoutRect.top) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);
        _boundary.top = true;
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;
```

#### 缩放回弹效果以及拖拽惯性效果
``` dart
void _handleScaleEnd(ScaleEndDetails details) {
    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_gestureDetails.totalScale > _gestureConfig.maxScale) {
      final double velocity =
          (_gestureDetails.totalScale - _gestureConfig.maxScale) /
              _gestureConfig.maxScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.maxScale, velocity);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_gestureDetails.totalScale < _gestureConfig.minScale) {
      final double velocity =
          (_gestureConfig.minScale - _gestureDetails.totalScale) /
              _gestureConfig.minScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.minScale, velocity);
      return;
    }

    if (_gestureDetails.gestureState == GestureState.pan) {
      // get magnitude from gesture velocity
      final double magnitude = details.velocity.pixelsPerSecond.distance;

      // do a significant magnitude
      if (magnitude >= minMagnitude) {
        final Offset direction = details.velocity.pixelsPerSecond /
            magnitude *
            _gestureConfig.inertialSpeed;

        _gestureAnimation.animationOffset(
            _gestureDetails.offset, _gestureDetails.offset + direction);
      }
    }
  }
```
唯一注意的是Scale的回弹动画将以最后的缩放中心点为中心进行缩放，这样缩放动画才看起来舒服一些
``` dart
  //true: user zoom/pan
  //false: animation
  final bool userOffset;
  Offset _getCenter(Rect destinationRect) {
    if (!userOffset && _center != null) {
      return _center;
    }
```

## 在PageView里面缩放拖拽

![](https://user-gold-cdn.xitu.io/2019/4/8/169fa7d8f91ac1b6?w=292&h=519&f=gif&s=4500955)

### 用法
1.使用
`ExtendedImageGesturePageView`展示图片

2.设置GestureConfig的inPageView 为Ture

GestureConfig 参数说明

| 参数 | 描述 | 默认值 |
| ------ | ------ | ------ |
| inPageView | 是否使用ExtendedImageGesturePageView展示图片 | false |

### 实现过程

#### 手势冲突

这个场景需要关注的是手势的冲突问题，PageView里面是有水平或者垂直的手势的，会跟onScaleStart/onScaleUpdate/onScaleEnd有冲突。

最开始想的是手势应该有冒泡，是不是可以我监听到了之后，不向上冒泡，这样可以阻止PageView里面的滑动行为，最后结论是没有方法能阻止冒泡。

关于手势，大家可以看看 [拉面小姐姐关于手势的文章](https://www.jianshu.com/p/228b2d043bca)，神奇的竞技场概念。。

既然不能阻止手势冒泡，那么我就直接不让你能滚动了，然后全部的手势都交给我，我来处理。

首先我看了下PageView关于滚动的源码，直接指向最终ScrollableState里面的代码，在setCanDrag方法里面根据是否可以Drag，准备了水平/垂直的手势。

把ScrollableState里面关于水平垂直滚动处理的代码拿出来，我创建了一个属于[extended_image](https://github.com/fluttercandies/extended_image)专门的[extended_image_gesture_page_view](https://github.com/fluttercandies/extended_image/blob/master/lib/src/gesture/extended_image_gesture_page_view.dart),属性跟PageView一样，只是没法设置physics，
因为强制设置为了NeverScrollableScrollPhysics
``` dart
    Widget result = PageView.custom(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      childrenDelegate: widget.childrenDelegate,
      pageSnapping: widget.pageSnapping,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      key: widget.key,
    );

    result = RawGestureDetector(
      gestures: _gestureRecognizers,
      behavior: HitTestBehavior.opaque,
      child: result,
    );
```
然后我们通过RawGestureDetector来注册_gestureRecognizers（水平/垂直的手势）。

关于_gestureRecognizers，我之前一直好奇PageView里面有个手hold的操作是怎么做到了，直到看到源码才知道这么个东西，源码真是个好东西。
``` dart
 void _handleDragDown(DragDownDetails details) {
    //print(details);
    _gestureAnimation.stop();
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }
```
#### 到达边界滚动上下一个图片
有了之前缩放拖拽的基础，这部分就比较简单了。如果到达边界就是用默认代码去操作PageView，否则就控制Image进行拖拽操作
``` dart
void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    var delta = details.delta;

    if (extendedImageGestureState != null) {
      var gestureDetails = extendedImageGestureState.gestureDetails;
      if (gestureDetails != null) {
        if (gestureDetails.movePage(delta)) {
          _drag?.update(details);
        } else {
          extendedImageGestureState.gestureDetails = GestureDetails(
              offset: gestureDetails.offset +
                  delta * extendedImageGestureState.imageGestureConfig.speed,
              totalScale: gestureDetails.totalScale,
              gestureDetails: gestureDetails);
        }
      } else {
        _drag?.update(details);
      }
    } else {
      _drag?.update(details);
    }
  }
``` 
#### 拖拽惯性效果
在DragEnd的时候，我们需要注意下处理下惯性。
当图片是放大状态而且水平或者垂直能够滑动的时候，我们需要_drag停止下来，以防止直接滑动到上一个或者下一个图片
`DragEndDetails(primaryVelocity: 0.0)`，并且根据惯性让图片在范围内继续惯性滑动。

``` dart
void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);

    var temp = details;

    if (extendedImageGestureState != null) {
      var gestureDetails = extendedImageGestureState.gestureDetails;

     if (gestureDetails != null &&
          gestureDetails.totalScale > 1.0 &&
          (gestureDetails.computeHorizontalBoundary ||
              gestureDetails.computeVerticalBoundary)) {
        //stop
        temp = DragEndDetails(primaryVelocity: 0.0);

        // get magnitude from gesture velocity
        final double magnitude = details.velocity.pixelsPerSecond.distance;

        // do a significant magnitude
        if (magnitude >= minMagnitude) {
          Offset direction = details.velocity.pixelsPerSecond /
              magnitude *
              (extendedImageGestureState.imageGestureConfig.inertialSpeed);

          if (widget.scrollDirection == Axis.horizontal) {
            direction = Offset(direction.dx, 0.0);
          } else {
            direction = Offset(0.0, direction.dy);
          }

          _gestureAnimation.animationOffset(
              gestureDetails.offset, gestureDetails.offset + direction);
        }
      }
    }

    _drag?.end(temp);

    assert(_drag == null);
  }
```

整个 [extended_image](https://github.com/fluttercandies/extended_image) 的缩放和拖拽功能就介绍完毕了，再吐槽下这个手势，用起来真不舒服，希望Flutter小组有更好的方案。

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image)
最后放上 [extended_image](https://github.com/fluttercandies/extended_image)，如果你有什么不明白或者对这个方案有什么改进的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)


![](https://user-gold-cdn.xitu.io/2019/4/8/169fa8932686dde7?w=226&h=226&f=png&s=7110)



