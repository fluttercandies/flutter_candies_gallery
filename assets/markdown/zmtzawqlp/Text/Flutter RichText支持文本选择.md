## [extended text](https://github.com/fluttercandies/Extended_Text) 相关文章

- [Flutter RichText支持图片显示和自定义图片效果](https://juejin.im/post/6844903797911732238)
- [Flutter RichText支持自定义文本溢出效果](https://juejin.im/post/6844903800302485511)
- [Flutter RichText支持自定义文字背景](https://juejin.im/post/6844903801808224263)
- [Flutter RichText支持特殊文字效果](https://juejin.im/post/6844903806098997262)
- [Flutter RichText支持文本选择](https://juejin.im/post/6844903863556767751)

[![pub package](https://img.shields.io/pub/v/extended_text.svg)](https://pub.dartlang.org/packages/extended_text)

[群花](https://juejin.im/user/4265760846775533)某天说，你咋不做下文本选择的需求呢，刚需呢。是吗？ 我咋都没看到有人提过呢？

前面做了[extended_text_field](https://github.com/fluttercandies/extended_text_field),里面有光标和文本选择的处理，本来想直接把改改，把光标去掉,然后不让修改。但是想了下，怎么能这么随便呢，还是拿起了[extended_text](https://github.com/fluttercandies/extended_text)魔改起来。


![](https://user-gold-cdn.xitu.io/2019/6/12/16b4985db1e4c3df?w=360&h=640&f=gif&s=461712)

| 参数                  | 描述                                                 | 默认                                                                         |
| --------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| selectionEnabled      | 是否开启文本选择功能                                 | false                                                                        |
| selectionColor        | 文本选择的颜色                                       | Theme.of(context).textSelectionColor                                         |
| dragStartBehavior     | 文本选择的拖拽行为                                   | DragStartBehavior.start                                                      |
| textSelectionControls | 文本选择控制器，你可以通过重写，来定义工具栏和选择器 | extendedMaterialTextSelectionControls/extendedCupertinoTextSelectionControls |

### 文本选择控制器

extended_text提供了默认的控制器extendedMaterialTextSelectionControls/extendedCupertinoTextSelectionControls 

你可以通过重写，来定义工具栏和选择器

下面是一个自定义的工具栏

```dart
class MyExtendedMaterialTextSelectionControls
    extends ExtendedMaterialTextSelectionControls {
  @override
  Widget buildToolbar(BuildContext context, Rect globalEditableRegion,
      Offset position, TextSelectionDelegate delegate) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return ConstrainedBox(
      constraints: BoxConstraints.tight(globalEditableRegion.size),
      child: CustomSingleChildLayout(
        delegate: ExtendedTextSelectionToolbarLayout(
          MediaQuery.of(context).size,
          globalEditableRegion,
          position,
        ),
        child: _TextSelectionToolbar(
          handleCopy: canCopy(delegate) ? () => handleCopy(delegate) : null,
          handleSelectAll:
              canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
          handleLike: () {
            //mailto:<email address>?subject=<subject>&body=<body>, e.g.
            launch(
                "mailto:zmtzawqlp@live.com?subject=extended_text_share&body=${delegate.textEditingValue.text}");
            delegate.hideToolbar();
          },
        ),
      ),
    );
  }
}

/// Manages a copy/paste text selection toolbar.
class _TextSelectionToolbar extends StatelessWidget {
  const _TextSelectionToolbar(
      {Key key, this.handleCopy, this.handleSelectAll, this.handleLike})
      : super(key: key);

  final VoidCallback handleCopy;
  final VoidCallback handleSelectAll;
  final VoidCallback handleLike;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    if (handleCopy != null)
      items.add(FlatButton(
          child: Text(localizations.copyButtonLabel), onPressed: handleCopy));
    if (handleSelectAll != null)
      items.add(FlatButton(
          child: Text(localizations.selectAllButtonLabel),
          onPressed: handleSelectAll));
    if (handleLike != null)
      items.add(FlatButton(child: Icon(Icons.favorite), onPressed: handleLike));

    return Material(
      elevation: 1.0,
      child: Container(
        height: 44.0,
        child: Row(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

```

### 工具栏和选择器的控制

你可以通过将你的页面包裹到ExtendedTextSelectionPointerHandler里面来定义不同的行为效果。

#### 默认行为

通过赋值ExtendedTextSelectionPointerHandler的child为你的页面，将会有默认的行为

```dart
 return ExtendedTextSelectionPointerHandler(
      //default behavior
       child: result,
    );
```

- 当点击extended_text之外的区域的时候，关闭工具栏和选择器
- 滚动的时候，关闭工具栏和选择器

#### 自定义行为

你可以通过builder方法获取到页面上面的全部的selectionStates(ExtendedTextSelectionState)，并且通过自己获取点击事件来处理工具栏和选择器

```dart
 return ExtendedTextSelectionPointerHandler(
      //default behavior
      // child: result,
      //custom your behavior
      builder: (states) {
        return Listener(
          child: result,
          behavior: HitTestBehavior.translucent,
          onPointerDown: (value) {
            for (var state in states) {
              if (!state.containsPosition(value.position)) {
                //clear other selection
                state.clearSelection();
              }
            }
          },
          onPointerMove: (value) {
            //clear other selection
            for (var state in states) {
              state.clearSelection();
            }
          },
        );
      },
    );
```

### 关于extended_text的readme
最近重新整理了一下readme，并且提供了中文文档，因为大家老是吐槽不容易看，希望新的readme能帮助大家更好地使用这个组件。

最后放上 [extended_text](https://github.com/fluttercandies/extended_text)，如果你有什么不明白或者对这个方案有什么改进的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)