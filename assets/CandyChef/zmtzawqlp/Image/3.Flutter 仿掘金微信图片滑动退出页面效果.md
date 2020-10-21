[extended_image](https://github.com/fluttercandies/extended_image) 相关文章

- [Flutter 什么功能都有的Image](https://juejin.im/post/6844903794656952328)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/6844903814324027400)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/6844903860163575815)
- [Flutter 图片裁剪旋转翻转编辑器](https://juejin.im/post/6844903939670802446)

**2019/06/16 更新：**

**1.增加onSlidingPage回调，可以在滑动页面的时候设置页面上面的其他元素的状态**

**2.增加中文文档**

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image)

这个需求在做[extended_image](https://github.com/fluttercandies/extended_image)的时候就有上帝客户提过了，一直都没有时间去考虑实现。最近思考了一下，把效果给实现了。

![](https://user-gold-cdn.xitu.io/2019/6/16/16b60054bf00b285?w=360&h=640&f=gif&s=3172679)

### 首先开启滑动退出页面效果

ExtendedImage

| parameter          | description              | default |
| ------------------ | ------------------------ | ------- |
| enableSlideOutPage | 是否开启滑动退出页面效果 | false   |

### 把你的页面用ExtendedImageSlidePage包一下

注意：onSlidingPage回调，你可以使用它来设置滑动页面的时候,页面上其他元素的状态。但是注意别直接使用setState来刷新，因为这样会导致ExtendedImage的状态重置掉，你应该只通知需要刷新的Widgets进行刷新

```dart
    return ExtendedImageSlidePage(
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        var showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );
```

ExtendedImageGesturePage的参数

| parameter                  | description                                                           | default                           |
| -------------------------- | --------------------------------------------------------------------- | --------------------------------- |
| child                      | 需要包裹的页面                                                        | -                                 |
| slidePageBackgroundHandler | 在滑动页面的时候根据Offset自定义整个页面的背景色                      | defaultSlidePageBackgroundHandler |
| slideScaleHandler          | 在滑动页面的时候根据Offset自定义整个页面的缩放值                      | defaultSlideScaleHandler          |
| slideEndHandler            | 滑动页面结束的时候计算是否需要pop页面                                 | defaultSlideEndHandler            |
| slideAxis                  | 滑动页面的方向（both,horizontal,vertical）,掘金是vertical，微信是Both | both                              |
| resetPageDuration          | 滑动结束，如果不pop页面，整个页面回弹动画的时间                       | milliseconds: 500                 |
| slideType                  | 滑动整个页面还是只是图片(wholePage/onlyImage)                         | SlideType.onlyImage               |
| onSlidingPage              | 滑动页面的回调，你可以在这里改变页面上其他元素的状态                  | -                                 |

下面是默认实现，你也可以根据你的喜好，来定义属于自己方式
```dart
Color defaultSlidePageBackgroundHandler(
    {Offset offset, Size pageSize, Color color, SlideAxis pageGestureAxis}) {
  double opacity = 0.0;
  if (pageGestureAxis == SlideAxis.both) {
    opacity = offset.distance /
        (Offset(pageSize.width, pageSize.height).distance / 2.0);
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    opacity = offset.dx.abs() / (pageSize.width / 2.0);
  } else if (pageGestureAxis == SlideAxis.vertical) {
    opacity = offset.dy.abs() / (pageSize.height / 2.0);
  }
  return color.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
}

bool defaultSlideEndHandler(
    {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
  if (pageGestureAxis == SlideAxis.both) {
    return offset.distance >
        Offset(pageSize.width, pageSize.height).distance / 3.5;
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    return offset.dx.abs() > pageSize.width / 3.5;
  } else if (pageGestureAxis == SlideAxis.vertical) {
    return offset.dy.abs() > pageSize.height / 3.5;
  }
  return true;
}

double defaultSlideScaleHandler(
    {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
  double scale = 0.0;
  if (pageGestureAxis == SlideAxis.both) {
    scale = offset.distance / Offset(pageSize.width, pageSize.height).distance;
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    scale = offset.dx.abs() / (pageSize.width / 2.0);
  } else if (pageGestureAxis == SlideAxis.vertical) {
    scale = offset.dy.abs() / (pageSize.height / 2.0);
  }
  return max(1.0 - scale, 0.8);
}
```
### 确保你的页面是透明背景的
如果你设置 slideType =SlideType.onlyImage, 请确保的你页面是透明的，毕竟没法操控你页面上的颜色

### Push一个透明的页面

这里我把官方的MaterialPageRoute 和CupertinoPageRoute拷贝出来了，
改为TransparentMaterialPageRoute/TransparentCupertinoPageRoute，因为它们的opaque不能设置为false

```dart
  Navigator.push(
    context,
    Platform.isAndroid
        ? TransparentMaterialPageRoute(builder: (_) => page)
        : TransparentCupertinoPageRoute(builder: (_) => page),
  );
```

嗯应该还算使用简单吧？群里的小伙伴吐槽表情包太多，不让放，蓝瘦香菇。


### 实现中的一些坑
#### 1.手势跟缩放拖拽以及PageView之前的关系和冲突
开始我的思路是想在ExtendedImageSlidePage 注册手势监听事件，然后ExtendedImageGesture里面当条件满足(达到边界/无法拖拽)的时候通知
ExtendedImageSlidePage 开始滑动页面手势了，可以阻止ExtendedImageSlidePage的child的hittest。

但是在实际中发现，在ExtendedImageGesture手势未完成之前（手指抬起）,ExtendedImageSlidePage 也是获取不到任何手势，而且IgnorePointer 也是不会生效的

后面干脆直接把手势接收都放ExtendedImageGesture里面了，直接通知ExtendedImageSlidePage进行translate和scale

#### 2.透明页面
TransparentMaterialPageRoute/TransparentCupertinoPageRoute
因为需要整个页面是透明的，所以重写了官方的。

但是在pop页面的时候还是有不满意的地方，比如ios上面有个从左到右Shadow，安卓上面整个页面也有Shadow。

通过修改官方源码，去掉了这些效果，感兴趣的小伙伴可以查看[extended_image_slide_page_route.dart](https://github.com/fluttercandies/extended_image/blob/master/lib/src/gesture/extended_image_slide_page_route.dart)（最近拉面批评代码上太多，差评，那个啥代码就不贴了
）

### 关于extended_image的readme
最近重新整理了一下readme，因为大家老是吐槽不容易看，希望新的readme能帮助大家更好地使用这个组件，感谢[财经龙大佬](https://juejin.im/user/4230576473650888)百忙当中帮忙格式readme，懒惰的程序猿，readme都要大佬帮忙弄，羞愧。。。

最后放上 [extended_image](https://github.com/fluttercandies/extended_image)，如果你有什么不明白或者对这个方案有什么改进的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)