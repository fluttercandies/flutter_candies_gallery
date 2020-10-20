[extended_image](https://github.com/fluttercandies/extended_image) 相关文章

- [Flutter 什么功能都有的Image](https://juejin.im/post/6844903794656952328)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/6844903814324027400)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/6844903860163575815)
- [Flutter 图片裁剪旋转翻转编辑器](https://juejin.im/post/6844903939670802446)

![](https://user-gold-cdn.xitu.io/2019/9/11/16d1c45c6067b5bd?w=360&h=640&f=gif&s=3489734)

图片编辑这个功能很早之前就想把它给做了，毕竟是做的全家桶，少一个功能都觉得不舒服。最近自己一个人在家，周末疯狂写了2天代码，睡觉都在思考，

![](https://user-gold-cdn.xitu.io/2019/9/11/16d1c5eff2c0bdfe?w=1280&h=565&f=jpeg&s=122628)
恰巧今天Google大会，据说现在掘金Flutter相关 约2万粉丝，2600多篇相关文章。我晚上回家撸到半夜总算是完成，嗯，文章+1了
![](https://user-gold-cdn.xitu.io/2019/9/11/16d1c64028db74f5?w=160&h=135&f=gif&s=4548)

## 实现

这部分我觉得不太好讲，全是数学几何相关的计算。当初开始写的[extended_image](https://github.com/fluttercandies/extended_image)的时候，就留意了一下可能会扩展的功能实现的可能性，代码之间也做好了铺垫。大家都问，功能能抽离出来吗？ 我说不能，从开始基础就决定它将会拥有这些功能。简单提一下，图片的显示区域不等于图片的layout区域，它受BoxFix等参数的影响。而Flutter里面的  Transform是对整个layout区域起作用的，明显不符合我们的需求。所以从一开始我就放弃直接使用Transform对图片进行处理，直接通过算法在绘制图片的时候进行缩放，平移，旋转，翻转等操作。

 Rome is not built in one day，[extended_image](https://github.com/fluttercandies/extended_image)从今年2月份开始编写的，到9月份最终成为各种常用实用功能的图片全家桶。 如果对实现感兴趣的小伙伴，可以先看看源码，如果有不清楚的，可以加群(QQ群:181398081)询问。

## 使用

``` dart
    ExtendedImage.network(
      imageTestUrl,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (state) {
        return EditorConfig(
            maxScale: 8.0,
            cropRectPadding: EdgeInsets.all(20.0),
            hitTestSize: 20.0,
            cropAspectRatio: _aspectRatio.aspectRatio);
      },
    );
```

ExtendedImage 相关参数设置

| 参数                     | 描述                                                                    | 默认 |
| ------------------------ | ----------------------------------------------------------------------- | ---- |
| mode                     | 图片模式，默认/手势/编辑 (none,gestrue,editor)                          | none |
| initGestureConfigHandler | 编辑器配置的回调(图片加载完成时).你可以根据图片的信息比如宽高，来初始化 | -    |
| extendedImageEditorKey   | key of ExtendedImageEditorState 用于裁剪旋转翻转                        | -    |

EditorConfig 参数

| 参数                   | 描述                                                                             | 默认                                                         |
| ---------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| maxScale               | 最大的缩放倍数                                                                   | 5.0                                                          |
| cropRectPadding        | 裁剪框跟图片layout区域之间的距离。最好是保持一定距离，不然裁剪框边界很难进行拖拽 | EdgeInsets.all(20.0)                                         |
| cornerSize             | 裁剪框四角图形的大小                                                             | Size(30.0, 5.0)                                              |
| cornerColor            | 裁剪框四角图形的颜色                                                             | primaryColor                                                 |
| lineColor              | 裁剪框线的颜色                                                                   | scaffoldBackgroundColor.withOpacity(0.7)                     |
| lineHeight             | 裁剪框线的高度                                                                   | 0.6                                                          |
| eidtorMaskColorHandler | 蒙层的颜色回调，你可以根据是否手指按下来设置不同的蒙层颜色                       | scaffoldBackgroundColor.withOpacity(pointerdown ? 0.4 : 0.8) |
| hitTestSize            | 裁剪框四角以及边线能够拖拽的区域的大小                                           | 20.0                                                         |
| animationDuration      | 当裁剪框拖拽变化结束之后，自动适应到中间的动画的时长                             | Duration(milliseconds: 200)                                  |
| tickerDuration         | 当裁剪框拖拽变化结束之后，多少时间才触发自动适应到中间的动画                     | Duration(milliseconds: 400)                                  |
| cropAspectRatio        | 裁剪框的宽高比                                                                   | null(无宽高比))                                              |
| initCropRectType       | 剪切框的初始化类型(根据图片初始化区域或者图片的layout区域)                       | imageRect                                                    |

### 裁剪框的宽高比 

这是一个double类型，你可以自定义裁剪框的宽高比。
如果为null，那就没有宽高比限制。
如果小于等于0，宽高比等于图片的宽高比。
下面是一些定义好了的宽高比

``` dart
class CropAspectRatios {
  /// no aspect ratio for crop
  static const double custom = null;

  /// the same as aspect ratio of image
  /// [cropAspectRatio] is not more than 0.0, it's original
  static const double original = 0.0;

  /// ratio of width and height is 1 : 1
  static const double ratio1_1 = 1.0;

  /// ratio of width and height is 3 : 4
  static const double ratio3_4 = 3.0 / 4.0;

  /// ratio of width and height is 4 : 3
  static const double ratio4_3 = 4.0 / 3.0;

  /// ratio of width and height is 9 : 16
  static const double ratio9_16 = 9.0 / 16.0;

  /// ratio of width and height is 16 : 9
  static const double ratio16_9 = 16.0 / 9.0;
}
```
### 旋转,翻转,重置

- 定义key，以方便操作ExtendedImageEditorState
  
 `final GlobalKey<ExtendedImageEditorState> editorKey =GlobalKey<ExtendedImageEditorState>();`

- 顺时针旋转90°
  
 `editorKey.currentState.rotate(right: true);`

- 逆时针旋转90°
  
 `editorKey.currentState.rotate(right: false);`

- 翻转(镜像)
  
 `editorKey.currentState.flip();`

- 重置
  
 `editorKey.currentState.reset();`

#### 使用dart库(稳定)

- 添加 [Image](https://github.com/brendan-duncan/image) 库到 pubspec.yaml, 它是用来裁剪/旋转/翻转图片数据的
  
``` yaml
dependencies:
  image: any
```

- 从ExtendedImageEditorState中获取裁剪区域以及图片数据
``` dart
  ///crop rect base on raw image
  final Rect cropRect = state.getCropRect();

  var data = state.rawImageData;
``` 
- 将flutter的图片数据转换为image库的数据
``` dart
  /// it costs much time and blocks ui.
  //Image src = decodeImage(data);

  /// it will not block ui with using isolate.
  //Image src = await compute(decodeImage, data);
  //Image src = await isolateDecodeImage(data);
  final lb = await loadBalancer;
  Image src = await lb.run<Image, List<int>>(decodeImage, data);
``` 
- 翻转，旋转，裁剪数据
``` dart
  //相机拍照的图片带有旋转，处理之前需要去掉
  src = bakeOrientation(src);

  if (editAction.needCrop)
    src = copyCrop(src, cropRect.left.toInt(), cropRect.top.toInt(),
        cropRect.width.toInt(), cropRect.height.toInt());

  if (editAction.needFlip) {
    Flip mode;
    if (editAction.flipY && editAction.flipX) {
      mode = Flip.both;
    } else if (editAction.flipY) {
      mode = Flip.horizontal;
    } else if (editAction.flipX) {
      mode = Flip.vertical;
    }
    src = flip(src, mode);
  }

  if (editAction.hasRotateAngle) src = copyRotate(src, editAction.rotateAngle);
``` 
- 将数据转为为图片的元数据
  
获取到的将是图片的元数据，你可以使用它来保存或者其他的一些用途

``` dart
  /// you can encode your image
  ///
  /// it costs much time and blocks ui.
  //var fileData = encodeJpg(src);

  /// it will not block ui with using isolate.
  //var fileData = await compute(encodeJpg, src);
  //var fileData = await isolateEncodeImage(src);
  var fileData = await lb.run<List<int>, Image>(encodeJpg, src);
``` 

#### 使用原生库(快速)

- 添加 [ImageEditor](https://github.com/fluttercandies/flutter_image_editor) 库到 pubspec.yaml, 它是用来裁剪/旋转/翻转图片数据的。
  
``` yaml
dependencies:
  image_editor: any
```

- 从ExtendedImageEditorState中获取裁剪区域以及图片数据
``` dart
  ///crop rect base on raw image
  final Rect cropRect = state.getCropRect();

  final img = state.rawImageData;
``` 
- 准备裁剪选项
``` dart
  final rotateAngle = action.rotateAngle.toInt();
  final flipHorizontal = action.flipY;
  final flipVertical = action.flipX;

  ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) option.addOption(ClipOption.fromRect(cropRect));

  if (action.needFlip)
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));

  if (action.hasRotateAngle) option.addOption(RotateOption(rotateAngle));
``` 

- 使用editImage方法进行裁剪 
  
获取到的将是图片的元数据，你可以使用它来保存或者其他的一些用途

``` dart
  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );
``` 

[更多细节](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/crop_editor_helper.dart)

## 结语

时间过得真快，搞弄flutter也快要1年了，认识不少朋友，大家在一起互相学习，促进的感觉真好。欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果(QQ群:181398081)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)