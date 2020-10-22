## [extended text](https://github.com/fluttercandies/Extended_Text) 相关文章

- [Flutter RichText支持图片显示和自定义图片效果](https://juejin.im/post/6844903797911732238)
- [Flutter RichText支持自定义文本溢出效果](https://juejin.im/post/6844903800302485511)
- [Flutter RichText支持自定义文字背景](https://juejin.im/post/6844903801808224263)
- [Flutter RichText支持特殊文字效果](https://juejin.im/post/6844903806098997262)
- [Flutter RichText支持文本选择](https://juejin.im/post/6844903863556767751)

之前介绍过了[Extended text](https://juejin.im/user/254742428916408/posts)，老规矩上图

![](https://user-gold-cdn.xitu.io/2019/3/16/16982b911fe7bace?w=1085&h=704&f=jpeg&s=166284)

UI设计说，那个字可以加个卟呤卟呤闪闪的背景吗？ 当然可以啊，没问题，我就去加，不就是TextStlye里面加个Background的吗？

那个啥。。我的中文字呢？
![](https://user-gold-cdn.xitu.io/2019/3/16/16982cd8aff4c003?w=352&h=78&f=png&s=6397)

又试了试，把背景色改成半透明的，中文字终于出来了，但是

![](https://user-gold-cdn.xitu.io/2019/3/16/16982ce7f58bf02b?w=544&h=76&f=png&s=3131)

尼玛，这个顶部高亮是什么鬼

![](https://user-gold-cdn.xitu.io/2019/3/16/16982cf0e44d2b6c?w=234&h=240&f=jpeg&s=5225)

也不吐槽了，想看bug的去[24335](https://github.com/flutter/flutter/issues/24335)和[24337](https://github.com/flutter/flutter/issues/24337)
看看，这个问题是我发现，@吉原拉面 姐姐帮忙验证，然后我们2个都开了issue，然后我的被关了，只剩下小姐姐的（有内情吗）。那个我可以@吉原拉面 吗，就是那个网红程序猿 吉原拉面

对产品设计说

![](https://user-gold-cdn.xitu.io/2019/3/16/16982d243e057e32?w=180&h=180&f=jpeg&s=4063)

被怂为啥别人别的平台能做啊，不管，必须支持。于是我又去看了下issue，去年的issue，都快4个月了。。搞什么鬼，修不修？ 算了，不修，老夫自己来画。。

[文本里面加入图片我们做过了](https://juejin.im/post/6844903797911732238)那么一切好像都是顺水成章的事情了。如果下面有哪里觉得讲的有点跳跃，请先看之前的那篇文章，谢谢。

先放出图
[![pub package](https://img.shields.io/pub/v/extended_text.svg)](https://pub.dartlang.org/packages/extended_text)
![](https://user-gold-cdn.xitu.io/2019/3/16/16982ec2a721a0b6?w=1080&h=1920&f=png&s=306716)

直接来到paint方法,还是循环找到BackgroundTextSpan
```dart
if (ts is BackgroundTextSpan) {
        var painter = ts.layout(_textPainter);
        Rect textRect = topLeftOffset & painter.size;
        Offset endOffset;
        if (textRect.right > rect.right) {
          int endTextOffset = textOffset + ts.toPlainText().length;
          endOffset = _findEndOffset(rect, endTextOffset);
        }

        ts.paint(canvas, topLeftOffset, rect, endOffset: endOffset);
      } else if (ts.children != null) {
        _paintSpecialTextChildren(ts.children, canvas, rect,
            textOffset: textOffset);
      }
      textOffset += ts.toPlainText().length;
```

这里我们要注意，因为你拿到的BackgroundTextSpan并且使用TextPainter出来的只能知道它整个文字的高度长度，不能直接知道它是否换行了，是否里面的文字是否文本溢出了，所以当文本最右边大于整个文本的右边的时候，就说明这个换行或者溢出了。使用_findEndOffset方法，我们从BackgroundTextSpan的最后一个字的位置向前找，直到找出BackgroundTextSpan最后一个不是文字溢出的位置

```dart
Offset _findEndOffset(Rect rect, int endTextOffset) {
    Offset endOffset = getOffsetForCaret(
      TextPosition(offset: endTextOffset, affinity: TextAffinity.upstream),
      rect,
    );
    //overflow
    if (endOffset == null || (endTextOffset != 0 && endOffset == Offset.zero)) {
      return _findEndOffset(rect, endTextOffset - 1);
    }
    return endOffset;
  }
```

找到之后就好办了,如果endOffset为null，说明可以直接画背景
```dart
  canvas.drawRect(textRect, background);
```
否则就说明这个BackgroundTextSpan有换行。
```dart
paint(Canvas canvas, Offset offset, Rect rect, {Offset endOffset})
```
那么就分为三部分:
1.offset 到整个文本的最右边
2.整行
3.整个文本的最左边到endOffset

其实应该很好理解，通过下面的算法，计算出中间是否有整行
```dart
      ///endOffset.y has deviation,so we calculate with text height
      ///print(((endOffset.dy - offset.dy) / _painter.height));
      var fullLinesAndLastLine =
          ((endOffset.dy - offset.dy) / _textPainterHelper.painter.height)
              .round();
```          
剩下的就是绘画了,[详见](https://github.com/fluttercandies/extended_text/blob/master/lib/src/background_text_span.dart)

到了这里，我们就已经解决掉了，中文字体和数字在一个TextSpan的时候Background的问题了。

但是这时候产品设计又来了，这是卟呤卟呤闪闪的背景？加个圆角可以不？
加个阴影可以不？？

当然可以，什么东西我不能画的，除了钱。。

于是我给BackgroundTextSpan加了clipBorderRadius圆角设置和paintBackground回调
```dart
  ///clip BorderRadius
  final BorderRadius clipBorderRadius;

  ///paint background by yourself
  final PaintBackground paintBackground;
```   
圆角设置简单。。[之前我们不就做过了](https://juejin.im/post/6844903797911732238)，[详见](https://github.com/fluttercandies/extended_text/blob/master/lib/src/background_text_span.dart)

PaintBackground 回调，给大家自己定义背景的机会。
```dart
             if (backgroundTextSpan.clipBorderRadius != null) {
                  canvas.save();
                canvas.clipPath(Path()
                  ..addRRect(backgroundTextSpan.clipBorderRadius
                         .resolve(painter.textDirection)
                         .toRRect(fullLineRect)));
                 }

               ///draw full line                              canvas.drawRect(
                      fullLineRect, backgroundTextSpan.background);

                  if (backgroundTextSpan.clipBorderRadius != null) {
                    canvas.restore();
                 }
```  
至于阴影，官方的[BoxDecoration](https://docs.flutter.io/flutter/painting/BoxDecoration-class.html)里面写的很详细，其实很多效果我都是看这个类才会的。。大家有空的话多看看源码能得到不少启示。

最后放上 [Github Extended_Text](https://github.com/fluttercandies/Extended_Text)，如果你有什么不明白的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)
