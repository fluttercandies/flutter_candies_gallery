[extended_image](https://github.com/fluttercandies/extended_image) 相关文章

- [Flutter 什么功能都有的Image](https://juejin.im/post/6844903794656952328)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/6844903814324027400)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/6844903860163575815)
- [Flutter 图片裁剪旋转翻转编辑器](https://juejin.im/post/6844903939670802446)

Pub上面关于Image的插件挺多的，但是为啥我还是想要做一个呢，主要是感觉pub上的不够自定义化。
[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image)

[extended_image](https://pub.dartlang.org/packages/extended_image)跟官方的用法一模一样，但是增加了许多实用的功能。

## 缓存网络图片
[ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image/blob/master/lib/src/extended_network_image_provider.dart)除了缓存的功能还提供了重试，超时等功能

```dart
 ExtendedNetworkImageProvider(this.url,
      {this.scale = 1.0,
      this.headers,
      this.cache: false,
      this.retries = 3,
      this.timeLimit,
      this.timeRetry = const Duration(milliseconds: 100)})
      : assert(url != null),
        assert(scale != null);

  ///time Limit to request image
  final Duration timeLimit;

  ///the time to retry to request
  final int retries;

  ///the time duration to retry to request
  final Duration timeRetry;

  ///whether cache image to local
  final bool cache;

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;  
```
或者你也可以这样用
```dart
ExtendedImage.network(
                url,
                cache: true,
              ),
```

## 圆角，边框，圆形
```dart
ExtendedImage.network(
                url,
                width: ScreenUtil.instance.setWidth(400),
                height: ScreenUtil.instance.setWidth(400),
                fit: BoxFit.fill,
                cache: true,
                border: Border.all(color: Colors.red, width: 1.0),
                shape: boxShape,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
```
## 清除本地缓存，清除内存缓存，保存网络图片到相册

清除本地缓存，你可以选择清楚全部，也可以给一个时间（清除比如7天之前的）
```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration}) 
```
清除内存缓存，这个是方便大家使用，调用的是系统api
```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```

保存图片到相册,使用到了image_picker_saver库，不同的是，支持把缓存到本地的图片直接保存到相册
```dart
saveNetworkImageToPhoto(String url, {bool useCache: true})
```

![](https://user-gold-cdn.xitu.io/2019/3/11/1696d367ce78dae1?w=360&h=640&f=gif&s=165793)

## 提供了回调 LoadStateChanged 方便根据状态订制加载，显示，失败等效果
这个功能不仅仅给网络图片使用，如果你读取的图片比较大，花费时间比较久，你依然可以用来定制加载效果

```dart
  ExtendedImage.network(
                  url,
                  width: ScreenUtil.instance.setWidth(600),
                  height: ScreenUtil.instance.setWidth(400),
                  fit: BoxFit.fill,
                  cache: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        _controller.reset();
                        return Image.asset(
                          "assets/loading.gif",
                          fit: BoxFit.fill,
                        );
                        break;
                      case LoadState.completed:
                        _controller.forward();
                        return FadeTransition(
                          opacity: _controller,
                          child: ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                            width: ScreenUtil.instance.setWidth(600),
                            height: ScreenUtil.instance.setWidth(400),
                          ),
                        );
                        break;
                      case LoadState.failed:
                        _controller.reset();
                        return GestureDetector(
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.asset(
                                "assets/failed.jpg",
                                fit: BoxFit.fill,
                              ),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Text(
                                  "load image failed, click to reload",
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            state.reLoadImage();
                          },
                        );
                        break;
                    }
                  },
                )
```

![](https://user-gold-cdn.xitu.io/2019/3/11/1696d39ebd0b85e9?w=360&h=640&f=gif&s=518305)

## 提供裁剪图片的方法
相信刷过微博的小伙伴都知道，微博里面的图片，是会根据图片的尺寸进行预览显示的，效果如下

![](https://user-gold-cdn.xitu.io/2019/3/11/1696d3b94dbebf6c?w=360&h=640&f=gif&s=2846675)

实现方法很简单，在LoadStateChanged 图片加载完成的状态中，你能拿到图片的image，得到图片的宽高，这个时候你就可以根据自己的设计计算出需要显示的图片的区域soucreRect

```dart
ExtendedRawImage(
        image: image,
        width: num400,
        height: num300,
        fit: BoxFit.fill,
        soucreRect: Rect.fromLTWH(
            (image.width - width) / 2.0, 0.0, width, image.height.toDouble()),
      )
```
[裁剪图片demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/crop_image_demo.dart)

# 提供了2个时机，你可以在绘画图片前和后，做你想做的任何事情
 BeforePaintImage 在绘画图片之前，如果你返回了true，那么自身的图片将不会绘制
 AfterPaintImage 在绘画图片之后
 
 在Demo中，主要展示了如何
 
 1.将图片剪切成一个心
 
 2.在图片之上绘画出一个心（制作你的水印有木有）
 
 3.[制作了一个下拉刷的图片,使用在里前一个裁剪图片的demo里面](https://github.com/fluttercandies/extended_image/tree/master/example/lib/common/push_to_refresh_header.dart)
 
 ```dart
 ExtendedImage.network(
                 url,
                 width: ScreenUtil.instance.setWidth(400),
                 height: ScreenUtil.instance.setWidth(400),
                 fit: BoxFit.fill,
                 cache: true,
                 beforePaintImage: (Canvas canvas, Rect rect, ui.Image image) {
                   if (paintType == PaintType.ClipHeart) {
                     if (!rect.isEmpty) {
                       canvas.save();
                       canvas.clipPath(clipheart(rect, canvas));
                     }
                   }
                   return false;
                 },
                 afterPaintImage: (Canvas canvas, Rect rect, ui.Image image) {
                   if (paintType == PaintType.ClipHeart) {
                     if (!rect.isEmpty) canvas.restore();
                   } else if (paintType == PaintType.PaintHeart) {
                     canvas.drawPath(
                         clipheart(rect, canvas),
                         Paint()
                           ..colorFilter = ColorFilter.mode(
                               Color(0x55ea5504), BlendMode.srcIn)
                           ..isAntiAlias = false
                           ..filterQuality = FilterQuality.low);
                   }
                 },
               )
 ```
 [Paint Image Demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/paint_image_demo.dart)
 
 
![](https://user-gold-cdn.xitu.io/2019/3/11/1696d49cba3d967c?w=360&h=640&f=gif&s=302489)


最后放上 [Github extended_image](https://github.com/fluttercandies/extended_image)，如果你有什么不明白的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)


![](https://user-gold-cdn.xitu.io/2019/3/20/1699a29d40f297ea?w=1920&h=1920&f=png&s=131155)

