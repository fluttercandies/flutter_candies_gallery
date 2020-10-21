## [extended text](https://github.com/fluttercandies/Extended_Text) 相关文章

- [Flutter RichText支持图片显示和自定义图片效果](https://juejin.im/post/6844903797911732238)
- [Flutter RichText支持自定义文本溢出效果](https://juejin.im/post/6844903800302485511)
- [Flutter RichText支持自定义文字背景](https://juejin.im/post/6844903801808224263)
- [Flutter RichText支持特殊文字效果](https://juejin.im/post/6844903806098997262)
- [Flutter RichText支持文本选择](https://juejin.im/post/6844903863556767751)



之前介绍过了[Extended text的图片功能](https://juejin.im/post/6844903797911732238)
，今天要讲的还是跟产品设计有关系，老规矩上图
![](https://user-gold-cdn.xitu.io/2019/3/16/16982b911fe7bace?w=1085&h=704&f=jpeg&s=166284)

产品说，那个文本溢出的点点点后面给我加个鸡腿，想什么啊，是加个 “全文”字样，点击之后跳转到全文去。

就像下面这种一样
[![pub package](https://img.shields.io/pub/v/extended_text.svg)](https://pub.dartlang.org/packages/extended_text)

![](https://user-gold-cdn.xitu.io/2019/3/16/16985700ac81bf2a?w=1080&h=990&f=jpeg&s=208593)

首先，我看了下Text的源码，发现这个...是被写死了的，传递给了TextPainter
```dart
const String _kEllipsis = '\u2026';
```
然后再向里面看，就是引擎绘画的代码了。。看不到了。。是我太弱了。
在google上搜索了下，发现也有问这个问题[26748](https://github.com/flutter/flutter/issues/26748)，上面也是说了。。需要把源码复制出来，把_kEllipsis改成你想要的，但是。。这个是个字符串啊。。那个比如说蓝色怎么弄？比如说点击怎么弄？

想来想去，一个字就是画，在Canvas上面尽情画。

![](https://user-gold-cdn.xitu.io/2019/3/16/169858028b4c0a64?w=600&h=395&f=gif&s=114836)

首先，我定义了一个TextSpan 用于用户自定义文本溢出效果
```dart
 overFlowTextSpan: OverFlowTextSpan(children: <TextSpan>[
                      TextSpan(text: '  \u2026  '),
                      TextSpan(
                          text: "more detail",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch(
                                  "https://github.com/fluttercandies/extended_text");
                            })
                    ], background: Theme.of(context).canvasColor),
```
然后我们直接来到ExtendedRenderParagraph的paint方法
``` dart
@override
  void paint(PaintingContext context, Offset offset) {
    _paintSpecialText(context, offset);
    _paint(context, offset);
    _paintTextOverflow(context, offset);
  }
```
这个效果肯定需要在画好字之后，再来魔改
``` dart
void _paintTextOverflow(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow && overFlowTextSpan != null) {
      final Canvas canvas = context.canvas;

      ///we will move the canvas, so rect top left should be (0,0)
      final Rect rect = Offset(0.0, 0.0) & size;
      var textPainter = overFlowTextSpan.layout(_textPainter);
      assert(textPainter.width <= rect.width,);
     
  }
```
首先我们需要layout一下我们的overFlowTextSpan，如果你定义的太长，已经超出一行了的话，那么抱歉
![](https://user-gold-cdn.xitu.io/2019/3/16/16982d243e057e32?w=180&h=180&f=jpeg&s=4063)

老动作，把画布移动到整个文字的左上角，根据overFlowTextSpanOffset的左上角，计算出最近的TextPosition。
``` dart
      canvas.save();

      ///move to extended text
      canvas.translate(offset.dx, offset.dy);

      final Offset overFlowTextSpanOffset = Offset(
          rect.width - textPainter.width, rect.height - textPainter.height);

      ///find TextPosition near overflow
      TextPosition overflowOffset =
          getPositionForOffset(overFlowTextSpanOffset);
```
再通过这个找出最近文字的top-left，这样才能保证不会剪切到半个或者不完全的文字。
``` dart
 ///find overflow TextPosition that not clip the original text
      Offset finalOverflowOffset = _findFinalOverflowOffset(
          rect, rect.width - textPainter.width, overflowOffset.offset);

 Offset _findFinalOverflowOffset(Rect rect, double x, int endTextOffset) {
    Offset endOffset = getOffsetForCaret(
      TextPosition(offset: endTextOffset, affinity: TextAffinity.upstream),
      rect,
    );
    //overflow
    if (endOffset == null || (endTextOffset != 0 && endOffset == Offset.zero)) {
      return _findFinalOverflowOffset(rect, x, endTextOffset - 1);
    }

    if (endOffset.dx > x) {
      return _findFinalOverflowOffset(rect, x, endTextOffset - 1);
    }
    return endOffset;
  } 
```

这样子我们就找到我们需要在哪个文字的位置把OverFlowTextSpan绘画出来，并且想办法把OverFlowTextSpan下一层的文字给清除或者遮挡住。

首先尝试是用BlendMode.clear来清除指定区域的文字，失败，不知道为什么，
我看别人也是这样子写的，能清除掉Canvas上面的内容，如果有哪个兄弟知道，请一定要告诉我，感谢万分。
```dart
      ///why BlendMode.clear not clear the text
//      canvas.saveLayer(overFlowTextSpanRect, Paint());
//      canvas.drawRect(
//          overFlowTextSpanRect,
//          Paint()
//            ..blendMode = BlendMode.clear);
//      canvas.restore();
```
那么只能画一层跟Canvas一样的颜色来遮住文字了。这里默认使用的是
``` dart
Theme.of(context).canvasColor
```

然后我们再画上OverFlowTextSpan
``` dart
 textPainter.paint(
          canvas, Offset(finalOverflowOffset.dx, overFlowTextSpanOffset.dy));
```

最后我们要处理一下点击事件，保存textPainter绘画的点（相对整个系统坐标的）
``` dart
overFlowTextSpan.textPainterHelper.saveOffset(Offset(
          offset.dx + finalOverflowOffset.dx,
          offset.dy + overFlowTextSpanOffset.dy));
```

在handleEvent方法中，我们加入以下代码,如果找到了对应注册了recognizer的TextSpan，我们就给它触发，并且return（因为overFlowTextSpan在原来的字的上一层）
``` dart
if (overFlowTextSpan != null) {
      final TextPosition position =
          overFlowTextSpan.textPainterHelper.getPositionForOffset(offset);
      final TextSpan span =
          overFlowTextSpan.textPainterHelper.getSpanForPosition(position);

      if (span?.recognizer != null) {
        span.recognizer.addPointer(event);
        return;
      }
    }
```
_offset是我们刚才保持的相对整个系统坐标的点，我们需要把传入的Offset减掉
_offset，这样这个overFlowTextSpan的相对自己的坐标系才是以（0，0）开始的，最后用这个TextPosition找到对应的TextSpan，大功告成。
``` dart
 ///method for [OverFlowTextSpan]
  ///offset int coordinate system
  Offset _offset;
  void saveOffset(Offset offset) {
    _offset = offset;
  }

  ///method for [OverFlowTextSpan]
  TextPosition getPositionForOffset(Offset offset) {
    return painter.getPositionForOffset(offset - _offset);
  }

  ///method for [OverFlowTextSpan]
  TextSpan getSpanForPosition(TextPosition position) {
    return painter.text.getSpanForPosition(position);
  }
```

除了清除（覆盖）文字的那个部分，其他应该都是比较完美的解决方案，期待大家能带来更多点子，改进[ Extended Text](https://github.com/fluttercandies/Extended_Text)

最后放上 [Github Extended_Text](https://github.com/fluttercandies/Extended_Text)，如果你有什么不明白的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

![](https://user-gold-cdn.xitu.io/2019/3/20/1699a29d40f297ea?w=1920&h=1920&f=png&s=131155)