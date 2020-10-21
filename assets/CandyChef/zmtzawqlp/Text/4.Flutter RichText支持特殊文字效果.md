## [extended text](https://github.com/fluttercandies/Extended_Text) 相关文章

- [Flutter RichText支持图片显示和自定义图片效果](https://juejin.im/post/6844903797911732238)
- [Flutter RichText支持自定义文本溢出效果](https://juejin.im/post/6844903800302485511)
- [Flutter RichText支持自定义文字背景](https://juejin.im/post/6844903801808224263)
- [Flutter RichText支持特殊文字效果](https://juejin.im/post/6844903806098997262)
- [Flutter RichText支持文本选择](https://juejin.im/post/6844903863556767751)


今天继续讲讲怎么样快速构建特殊文字以及自定义背景，我喜欢那个图，再次送上

![](https://user-gold-cdn.xitu.io/2019/3/16/16982b911fe7bace?w=1085&h=704&f=jpeg&s=166284)

大家刷微博应该都经常看到，文字里面有一些比如@某某某，或者一些话题的链接。但是服务器端一般都是给你一段文字，你需要自己去做匹配。以前可能每加个逻辑，你就要写一段代码，但是有了[Extended text](https://github.com/fluttercandies/extended_text)，一切都变得so easy。
[![pub package](https://img.shields.io/pub/v/extended_text.svg)](https://pub.dartlang.org/packages/extended_text)


举个栗子，比如我们要匹配@某某某，我们只需要继承SpecialText，并且定义它的开始标志和结束标志
```dart
class AtText extends SpecialText {
  static const String flag = "@";
  AtText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(flag, " ", textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    // TODO: implement finishText

    final String atText = toString();
    return TextSpan(
        text: atText,
        style: textStyle?.copyWith(color: Colors.blue, fontSize: 16.0),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap(atText);
          });
  }
}
```
然后，我们需要定义匹配规则,继承SpecialTextSpanBuilder，实现方法
```dart
class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(String data,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (data == null || data == "") return null;
    List<TextSpan> inlineList = new List<TextSpan>();
    if (data != null && data.length > 0) {
      SpecialText specialText;
      String textStack = "";
      //String text
      for (int i = 0; i < data.length; i++) {
        String char = data[i];
        if (specialText != null) {
          if (!specialText.isEnd(char)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
          }
        } else {
          textStack += char;
          specialText =
              createSpecialText(textStack, textStyle: textStyle, onTap: onTap);
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(
                  0, textStack.length - specialText.startFlag.length);
              if (textStack.length > 0) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = "";
          }
        }
      }

      if (specialText != null) {
        inlineList.add(TextSpan(
            text: specialText.startFlag + specialText.getContent(),
            style: textStyle));
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    }

    // TODO: implement build
    return TextSpan(children: inlineList, style: textStyle);
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (flag == null || flag == "") return null;
    // TODO: implement createSpecialText

    if (isStart(flag, AtText.flag)) {
      return AtText(textStyle, onTap);
    } else if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle);
    } else if (isStart(flag, DollarText.flag)) {
      return DollarText(textStyle, onTap);
    }
    return null;
  }
}

```

最后使用的时候是这样子的
```dart
ExtendedText(
          "[love]Extended text help you to build rich text quickly. any special text you will have with extended text. "
              "\n\nIt's my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love]"
              "\n\nif you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]",
          onSpecialTextTap: (String data) {
            if (data.startsWith("\$")) {
              launch("https://github.com/fluttercandies");
            } else if (data.startsWith("@")) {
              launch("mailto:zmtzawqlp@live.com");
            }
          },
          specialTextSpanBuilder: MySpecialTextSpanBuilder(),
          overflow: TextOverflow.ellipsis,
          //style: TextStyle(background: Paint()..color = Colors.red),
          maxLines: 10,
        ),
```
是不是觉得特别简单，而且可扩展性强，妈妈再也不会担心我没法做特殊文字的匹配了。。
上个效果图哈

![](https://user-gold-cdn.xitu.io/2019/3/16/16982c16fc4b89a0?w=1080&h=762&f=jpeg&s=141594)



最后放上 [Github Extended_Text](https://github.com/fluttercandies/Extended_Text)，如果你有什么不明白的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)
