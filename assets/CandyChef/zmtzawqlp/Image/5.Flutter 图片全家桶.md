大家好，我是戴着眼镜口罩会起雾的200。不得不说Flutter在UI方面，只要是能想到的效果，你用心都能实现。

图片是一个应用中的重要部分，展示，压缩，裁剪，pub三方库应该说是应有尽有。
[FlutterCandies](https://github.com/fluttercandies) 中也有多个关于图片的库,可以说是比较全面了。

#### [extended_image](https://github.com/fluttercandies/extended_image)

功能最全面的图片展示库，加粗为最近新增功能

主要功能 
* 缓存网络图片
* 加载状态(正在加载，完成，失败)
* 拖拽缩放图片
* 图片编辑(裁剪，旋转，翻转)
* 图片预览(跟微信掘金一样)
* 滑动退出效果(跟微信掘金一样)
* 设置圆角，边框
* **支持进度显示**
* **图片预览上滑显示详情(跟图虫一样)**

##### 支持进度显示
![](https://user-gold-cdn.xitu.io/2020/4/12/1716e83b0529fd76?w=450&h=800&f=gif&s=138928)

增加loadingProgress参数，用于显示进度。

``` dart
             ExtendedImage.network(
              'https://raw.githubusercontent.com/fluttercandies/flutter_candies/master/gif/extended_text/special_text.jpg',
              handleLoadingProgress: true,
              clearMemoryCacheIfFailed: true,
              clearMemoryCacheWhenDispose: true,
              cache: false,
              loadStateChanged: (ExtendedImageState state) {
                if (state.extendedImageLoadState == LoadState.loading) {
                  final loadingProgress = state.loadingProgress;
                  final progress = loadingProgress?.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 150.0,
                          child: LinearProgressIndicator(
                            value: progress,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text('${((progress ?? 0.0) * 100).toInt()}%'),
                      ],
                    ),
                  );
                }
                return null;
              },
            ),
```

##### 图片预览上滑显示详情(跟图虫一样)

![](https://user-gold-cdn.xitu.io/2020/4/12/1716e83c8d30070e?w=450&h=800&f=gif&s=4139680)

当时在制作图片预览功能的时候，就暴露多了足够的api，提供给用户自定义各种效果，
由于Flutter手势的复杂以及冲突，我特意做了一个Demo提供出来。

至此[pic_swiper.dart](https://github.com/fluttercandies/flutter_candies_demo_library/blob/master/lib/src/widget/pic_swiper.dart)已拥有以下功能:
* 缩放
* 平移
* 上下一页图片
* 拖动退出预览
* 上滑显示详情

#### [extended_image_library](https://github.com/fluttercandies/extended_image_library)

为extended_image的基础库，如果你只需要网络图片缓存功能，你可以只引用这个库
``` dart
    Image(
      image: ExtendedNetworkImageProvider("", cache: true),
    );
``` 

* 支持Web，[小姐姐在线Demo](https://fluttercandies.github.io/extended_image/)
* 提供获取缓存图片的各种方法
* 方便获取图片的原数据(image的toByteData方法性能不佳)

#### [flutter_image_editor](https://github.com/fluttercandies/flutter_image_editor)

![](https://user-gold-cdn.xitu.io/2019/10/30/16e1a6c908c2562d?w=360&h=640&f=gif&s=3489734)

flutter_image_editor可以说是低调为[extended_image](https://github.com/fluttercandies/extended_image)量身打造的原生插件，支持旋转裁剪翻转，extended_image负责图片编辑UI，flutter_image_editor提供原生裁剪图片数据能力。由于dart [image](https://pub.flutter-io.cn/packages/image)库在处理图片的效率问题，原生库(期待纯C++库)就有了很大的优势(大图片可以有10倍速度的提升)。

#### [flutter_wechat_assets_picker](https://github.com/fluttercandies/flutter_wechat_assets_picker)
出自[Flutter劝退师Alex](https://juejin.im/user/606586150596360)之手，
是一个对标微信的多选资源选择器，99%接近于原生微信的操作，纯Dart编写，支持选择的同时也支持预览资源。支持如下功能：

* 图片资源支持
* 视频资源支持
* 国际化支持
* 自定义文本支持

[原文章](https://juejin.im/post/6844904119191207944)

| ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d75ab1f7984f?imageView2/0/w/1280/h/960/format/webp/) | ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d75bdcf11330?imageView2/0/w/1280/h/960/format/webp/) |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d75db3b408ae?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) | ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d76147c624a0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) |
| ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d773cc45c182?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) | ![](https://user-gold-cdn.xitu.io/2020/4/9/1715d75658268478?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) |

#### 结语

如果觉得还差点意思，欢迎提建议，欢迎pr。

欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)