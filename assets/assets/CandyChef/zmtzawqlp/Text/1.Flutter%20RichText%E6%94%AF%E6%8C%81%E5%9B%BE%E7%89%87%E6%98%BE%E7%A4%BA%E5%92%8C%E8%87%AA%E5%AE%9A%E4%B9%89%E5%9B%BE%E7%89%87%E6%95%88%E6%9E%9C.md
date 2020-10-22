## [extended text](https://github.com/fluttercandies/Extended_Text) 相关文章

- [Flutter RichText支持图片显示和自定义图片效果](https://juejin.im/post/6844903797911732238)
- [Flutter RichText支持自定义文本溢出效果](https://juejin.im/post/6844903800302485511)
- [Flutter RichText支持自定义文字背景](https://juejin.im/post/6844903801808224263)
- [Flutter RichText支持特殊文字效果](https://juejin.im/post/6844903806098997262)
- [Flutter RichText支持文本选择](https://juejin.im/post/6844903863556767751)

大晚上的先上个图片震撼一下大家的心灵。

![](https://user-gold-cdn.xitu.io/2019/3/16/1698268a3192499b?w=1085&h=704&f=jpeg&s=166284)

文本中带有图片/表情，在现在的app中，是及其常见的事情，但是在Flutter当中，这是个缺失的功能。

就向上图一样，产品和UI设计是不可能放过我的。所以[Extended Text](https://github.com/fluttercandies/extended_text)就在这个天时地利人和的情况下诞生了。

[![pub package](https://img.shields.io/pub/v/extended_text.svg)](https://pub.dartlang.org/packages/extended_text)


花了些时间把Text的源码都看一遍，很自然的看到了最后用Canvas在画字，其实Flutter 的widget只是一个数据的壳，最终还是都会落实在Canvas上面。那么我们不是就可以在这个Canvas上面画我们像要的图片了吗？

答案当然是可以的,接下来，我们把源码Copy出来，魔改吧！！

![](https://user-gold-cdn.xitu.io/2019/3/16/169826ed0a0a2863?w=346&h=97&f=png&s=7863)

首先想到的是，这个图片，肯定也要占用文字的位置，那么我是不是可以画个透明的文字，然后在这个文字的位置上画图呢？

先百度了一下(感谢[RealRichText](https://github.com/bytedance/RealRichText )提供的思路)，\u200B 字符代表 ZERO WIDTH SPACE，就是宽带为0的空白，我拿TextPainter试了下，确实是这样，layout出来的Width总是0，不管fontSize是多少，当然高度会随fontSize变化。结合TextStyle里面的letterSpacing，这样我们就能控制这个图片文字的宽度了。

```dart
  /// The amount of space (in logical pixels) to add between each letter.
  /// A negative value can be used to bring the letters closer.
  final double letterSpacing;
 ```
 接下来，又是用TextPainter，计算出来26 fontSize的\u200B的高度为30DP，
 这样我们就知道怎么把图片文字的高度转为了文字的fontSize了。。
 ```dart
 //[imageSpanTransparentPlaceholder] width is zero,
///so that we can define letterSpacing as Image Span width
const String imageSpanTransparentPlaceholder = "\u200B";

///transparentPlaceholder is transparent text
//fontsize id define image height
//size = 30.0/26.0 * fontSize
///final double size = 30.0;
///fontSize 26 and text height =30.0
//final double fontSize = 26.0;

double dpToFontSize(double dp) {
  return dp / 30.0 * 26.0;
}
```
 
图片文字那么必然要有图片了，那么我们就提供个ImageProvider来装载图片，因为做过[extended image](https://juejin.im/post/6844903794656952328)，这部分不要太熟悉了，对image不了解的同学可以去看看 这个 [全能的Image](https://juejin.im/post/6844903794656952328)

当然我没有忘记给大家准备网络图片缓存的ImageProvider,以及清除它们的方法clearExtendedTextDiskCachedImages
```dart
 CachedNetworkImage(this.url,
      {this.scale = 1.0,
      this.headers,
      this.cache: false,
      this.retries = 3,
      this.timeLimit,
      this.timeRetry = const Duration(milliseconds: 100)})
      : assert(url != null),
        assert(scale != null);

/// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearExtendedTextDiskCachedImages({Duration duration}) async
```

需要注意的是，因为ImageSpan没法获取到BuildContext，所以我们需要在Extended text build的时候，把ImageProvider 所需要的ImageConfiguration准备好
 
```dart
 void _createImageConfiguration(List<TextSpan> textSpan, BuildContext context) {
    textSpan.forEach((ts) {
      if (ts is ImageSpan) {
        ts.createImageConfiguration(context);
      } else if (ts.children != null) {
        _createImageConfiguration(ts.children, context);
      }
    });
  }
```

接下来就要到核心绘画文字的类里面去了ExtendedRenderParagraph
在Paint方法中，在画字之前我们来处理这个图片(反正文字是透明的，而且0的width，只是有个与前后文字的距离（图片的宽）),在绘画图片的时候，我把画布移动到offset的地方，就是整个文字开始绘画的点，方便后面计算的绘画
``` dart
 void paint(PaintingContext context, Offset offset) {
    _paintSpecialText(context, offset);
    _paint(context, offset)；
  }
  
 void _paintSpecialText(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    canvas.save();
    ///move to extended text
    canvas.translate(offset.dx, offset.dy);

    ///we have move the canvas, so rect top left should be (0,0)
    final Rect rect = Offset(0.0, 0.0) & size;
    _paintSpecialTextChildren(<TextSpan>[text], canvas, rect);
    canvas.restore();
  }  
  
```
在_paintSpecialTextChildren中，循环找寻ImageSpan.
注意使用getOffsetForCaret方法，我们来判断这个TextSpan是否已经是文本溢出了。
``` dart
 Offset topLeftOffset = getOffsetForCaret(
        TextPosition(offset: textOffset),
        rect,
      );
      //skip invalid or overflow
      if (topLeftOffset == null ||
          (textOffset != 0 && topLeftOffset == Offset.zero)) {
        return;
      }
```
textOffset起始为0，当跳过一个TextSpan，我们加上该TextSpan的offset，然后继续查找
``` dart
textOffset += ts.toPlainText().length;
``` 
如果是一个ImageSpan，首先因为这个\u200B 没有宽度，而宽度是我们设置的letterSpacing，所以这个图片绘画的地方应该要向前移动width / 2.0
``` dart
    if (ts is ImageSpan) {
        ///imageSpanTransparentPlaceholder \u200B has no width, and we define image width by
        ///use letterSpacing,so the actual top-left offset of image should be subtract letterSpacing(width)/2.0
        Offset imageSpanOffset = topLeftOffset - Offset(ts.width / 2.0, 0.0);

        if (!ts.paint(canvas, imageSpanOffset)) {
          //image not ready
          ts.resolveImage(
              listener: (ImageInfo imageInfo, bool synchronousCall) {
            if (synchronousCall)
              ts.paint(canvas, imageSpanOffset);
            else {
              if (owner == null || !owner.debugDoingPaint) {
                markNeedsPaint();
              }
            }
          });
        }
      }
```
ImageSpan的paint方法，如果图片还没加载，那么我们需要resolveImage并且监听回调，在回调的时候，如果是一个同步的回调，那么这个时候Canvas应该不没有被dispose掉，那么我们就直接画上。否则判断owner，并且设置markNeedsPaint，让整个Text再次绘画。

上面就是怎么在文本中加入一个图片，然而产品可不是那么好对付的，产品说，那个图片给我加个圆角，加个Border，加个加载效果，给弄成圆形的，巴拉巴拉...说累了，你就直接按照下面的图来做吧。

![](https://user-gold-cdn.xitu.io/2019/3/16/16982978721261ad?w=320&h=569&f=gif&s=214762)

看到这样的需求，我的表情为
![](https://user-gold-cdn.xitu.io/2019/3/16/169829a6e7ffeebb?w=240&h=240&f=jpeg&s=6799)

不过其实掌握了Canvas的一些技巧之后，这点事情难不倒我,加上2个回调，在绘画图片之前和之后，做你想要做的任何事情。
``` dart
  ///you can paint your placeholder or clip
  ///any thing you want
  final BeforePaintImage beforePaintImage;

  ///you can paint border,shadow etc
  final AfterPaintImage afterPaintImage;
``` 
比如说在图片加载之后来个loading 占位,你可以这样做
``` dart
 ImageSpan(CachedNetworkImage(imageTestUrls.first), beforePaintImage:
                    (Canvas canvas, Rect rect, ImageSpan imageSpan) {
              bool hasPlaceholder = drawPlaceholder(canvas, rect, imageSpan);
              if (!hasPlaceholder) {
                clearRect(rect, canvas);
              }
              return false;
            },
```
画个背景，画个字，so easy
``` dart
  bool drawPlaceholder(Canvas canvas, Rect rect, ImageSpan imageSpan) {
    bool hasPlaceholder = imageSpan.imageSpanResolver.imageInfo?.image == null;

    if (hasPlaceholder) {
      canvas.drawRect(rect, Paint()..color = Colors.grey);
      var textPainter = TextPainter(
          text: TextSpan(text: "loading", style: TextStyle(fontSize: 10.0)),
          textAlign: TextAlign.center,
          textScaleFactor: 1,
          textDirection: TextDirection.ltr,
          maxLines: 1)
        ..layout(maxWidth: rect.width);

      textPainter.paint(
          canvas,
          Offset(rect.left + (rect.width - textPainter.width) / 2.0,
              rect.top + (rect.height - textPainter.height) / 2.0));
    }
    return hasPlaceholder;
  }

  void clearRect(Rect rect, Canvas canvas) {
    ///if don't save layer
    ///BlendMode.clear will show black
    ///maybe this is bug for blendMode.clear
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }
```

其他效果请参见 [自定义图片](https://github.com/fluttercandies/extended_text)


最后放上 [Github Extended_Text](https://github.com/fluttercandies/Extended_Text)，如果你有什么不明白的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

[Extended Text](https://github.com/fluttercandies/Extended_Text)的功能远远不只这些，将在下面的几篇文章中慢慢道来。

![](https://user-gold-cdn.xitu.io/2019/3/20/1699a29d40f297ea?w=1920&h=1920&f=png&s=131155)