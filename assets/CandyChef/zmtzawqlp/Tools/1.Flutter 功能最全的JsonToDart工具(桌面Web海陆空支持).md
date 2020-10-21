## [JsonToDart](https://github.com/fluttercandies/JsonToDart) 相关文章

- [Flutter 功能最全的JsonToDart工具(桌面Web海陆空支持)](https://juejin.im/post/6844903875833495566)
- [Flutter JsonToDart Mac版 lei了，真的不mark吗](https://juejin.im/post/6844903882330488845)
- [Flutter JsonToDart 工具](https://juejin.im/post/6844904138032037895)

**更新已支持Mac**

为什么要做这个工具呢？

1.老是被服务端坑，各种数据类型不对

2.参数命名混乱，强迫症根本不能忍

3.官方的不能自定义，然后我之前用的大佬们写的工具[debuggerx01大佬](https://github.com/debuggerx01/JSONFormat4Flutter)，[低调大佬](https://github.com/CaiJingLong/json2dart)，但是有些需求，还是不好老是麻烦大佬，就想着自己写方便一些


工具使用[UWP](https://baike.so.com/doc/23718184-24274055.html),[WPF](https://baike.so.com/doc/2917373-3078588.html)和[Silverlight](https://baike.so.com/doc/5402730-5640416.html)开发，原因如下：

1.我是一个C#喵，从开始学习java，到入坑微软做Xaml，Silverlight，WPF,WindowsPhone，UWP 全套灵活运用。在最大的componentone/grapecity控件公司呆过几年，转做Flutter之后继续专注自定义组件 [FlutterCandies](https://github.com/fluttercandies), 希望能分享更多的Flutter组件，为大家提供方便。 那个。。话题扯远了。。总结一下，我觉得用UWP/WPF/Silverlight 海陆空一套代码完成这个工具会很方便

2.也不是没有考虑用Dart写，毕竟支持web/windows/mac。但是我这个工具界面上面的布局，需要很多输入框进行自定义修改。Flutter现在的没有提供舒服的双向绑定方式，想一想每一个输入框就要一个control,头有点大。。

[功能最全面的Json转换Dart的工具](https://juejin.im/post/6844903875833495566)，支持Windows，Mac，Web以及Linux。

相关：
- [uwp](https://baike.so.com/doc/23718184-24274055.html)
- [wpf](https://baike.so.com/doc/2917373-3078588.html)
- [silverlight](https://baike.so.com/doc/5402730-5640416.html)
- [flutter](https://github.com/flutter/flutter)
- [flutter-desktop](https://github.com/google/flutter-desktop-embedding)
- [flutter-web](https://github.com/flutter/flutter_web)
- [go-flutter](https://github.com/go-flutter-desktop/go-flutter)
- [go](https://github.com/golang/go)
- [hover](https://github.com/go-flutter-desktop/hover)

Flutter Candies qq群181398081

- [下载](#%E4%B8%8B%E8%BD%BD)
- [安装](#%E5%AE%89%E8%A3%85)
  - [UWP(Windows10)](#UWPWindows10)
  - [WPF(Windows7/Windows8)](#WPFWindows7Windows8)
  - [Silverlight(Web)](#SilverlightWeb)
  - [Flutter(Mac)](#FlutterMac)
  - [Flutter(Windows_x64)](#FlutterWindowsx64)
- [使用](#%E4%BD%BF%E7%94%A8)
  - [格式化](#%E6%A0%BC%E5%BC%8F%E5%8C%96)
  - [更多设置](#%E6%9B%B4%E5%A4%9A%E8%AE%BE%E7%BD%AE)
    - [数据类型全方位保护](#%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B%E5%85%A8%E6%96%B9%E4%BD%8D%E4%BF%9D%E6%8A%A4)
    - [数组全方位保护](#%E6%95%B0%E7%BB%84%E5%85%A8%E6%96%B9%E4%BD%8D%E4%BF%9D%E6%8A%A4)
    - [遍历数组次数](#%E9%81%8D%E5%8E%86%E6%95%B0%E7%BB%84%E6%AC%A1%E6%95%B0)
    - [属性命名](#%E5%B1%9E%E6%80%A7%E5%91%BD%E5%90%8D)
    - [属性排序](#%E5%B1%9E%E6%80%A7%E6%8E%92%E5%BA%8F)
    - [添加保护方法](#%E6%B7%BB%E5%8A%A0%E4%BF%9D%E6%8A%A4%E6%96%B9%E6%B3%95)
    - [文件头部信息](#%E6%96%87%E4%BB%B6%E5%A4%B4%E9%83%A8%E4%BF%A1%E6%81%AF)
    - [属性访问器类型](#%E5%B1%9E%E6%80%A7%E8%AE%BF%E9%97%AE%E5%99%A8%E7%B1%BB%E5%9E%8B)
  - [修改json类信息](#%E4%BF%AE%E6%94%B9json%E7%B1%BB%E4%BF%A1%E6%81%AF)
  - [生成Dart](#%E7%94%9F%E6%88%90Dart)

# 下载

Github下载速度太慢，为了方便大家下载，特意在gitee也创建了下载地址。

[UWP 微软商店](https://www.microsoft.com/store/apps/9NBRW9451QSR)

[WPF for Windows](https://gitee.com/zmtzawqlp/JsonToDart/attach_files/379990/download)

[UWP for Windows10](https://gitee.com/zmtzawqlp/JsonToDart/attach_files/379991/download)

[Flutter for Macos](https://gitee.com/zmtzawqlp/JsonToDart/attach_files/379989/download)

[Flutter for Web](https://zmtzawqlp.gitee.io/jsontodartflutterweb)

| 平台    | 语言 | 描述                                                                                                    | 代码/安装包地址                                                                                                               |
| ------- | ---- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| windows | C#   | uwp构建，运行环境windows10，x86/x64                                                                     | [windows-uwp.zip](https://github.com/fluttercandies/JsonToDart/releases)                                                      |
| windows | C#   | wpf构建，运行环境windows10/windows8/widnows7，x86/x64                                                   | [windows-wpf.zip](https://github.com/fluttercandies/JsonToDart/releases)                                                      |
| windows | dart | flutter构建, 使用[官方方式](https://github.com/google/flutter-desktop-embedding)编译,x64 ,debug版本     | [windows-x64-flutter.zip](https://github.com/fluttercandies/JsonToDart/releases)                                              |
| windows | dart | flutter构建, 使用[go-flutter](https://github.com/go-flutter-desktop/go-flutter)编译,x64 ,debug版本      | [windows-x64-go-flutter.zip](https://github.com/fluttercandies/JsonToDart/releases)                                           |
| mac     | dart | flutter构建,使用[go-flutter](https://github.com/go-flutter-desktop/go-flutter)编译(官方方式,未找到产物) | [mac-go-flutter.zip](https://github.com/fluttercandies/JsonToDart/releases)                                                   |
| web     | C#   | [silverlight](https://baike.so.com/doc/5402730-5640416.html)构建, 需要安装silverlight插件，有浏览器限制 | [网页地址](https://fluttercandies.github.io/JsonToDart)和[带字体文件网页地址](https://fluttercandies.github.io/JsonToDartWeb) |
| web     | dart | [flutter-web](https://github.com/flutter/flutter_web)构建                                               | [网页地址]( https://fluttercandies.github.io/JsonToDartFlutterWeb/)                                                           |
| linux   | dart | flutter构建, 使用官方方式编译，(没有环境测试，假装可以用)                                               | [代码地址](https://github.com/fluttercandies/JsonToDart/tree/master/Flutter/desktop)                                          |                                          | [代码地址](https://github.com/fluttercandies/JsonToDart/tree/master/Flutter/desktop)                                          |

# 安装
## UWP(Windows10)

Windows10 用户

考虑到应用商店经常大姨妈，就没有上传到商店了。

下载好安装包，解压。

第一次安装，需要安装证书，请按照下图，使用PowerShell打开Add-AppDevPackage.ps1，一路接受就安装完毕


![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa0e2e7486f5?w=927&h=412&f=png&s=36682)

后面如果工具有更新，可以下载最新的，然后点击FlutterCandiesJsonToDart_x.0.x.0_x86_x64.appxbundle 安装

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa0fd101b7aa?w=1586&h=645&f=png&s=60498)

## WPF(Windows7/Windows8)

Windows7/Windows8 用户

下载解压，点击setup.exe安装

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa12378f96bb?w=486&h=220&f=png&s=7497)

## Silverlight(Web)

带字体文件是因为可能有乱码，由于中文字体问题，包含了中文字体文件，第一次会比较久，请耐心等待

首先需要安装[Silverlight](https://www.microsoft.com/getsilverlight/get-started/install/default?reason=unsupportedbrowser&_helpmsg=ChromeVersionDoesNotSupportPlugins#sysreq)

Mac的用户下载Mac的，Windows用户下载Windows的

然后就是浏览器问题了，因为支持Silverlight的浏览器是有限的，除了Internet Explorer支持，以下版本的浏览器也支持.

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa15b23e143d?w=1372&h=516&f=png&s=33736)

Mac [Safari 12.0以下的可以尝试这样开启插件](https://www.cnblogs.com/qiumingshanshangjian/p/8413165.html)

Mac [Firefox](https://mac.filehorse.com/download-firefox/7957/download/)这个版本能使用

## Flutter(Mac)

点击json_to_dart启动

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa1944a633cd?w=400&h=262&f=png&s=23909)

## Flutter(Windows_x64)

flutter官方产物或者go-flutter产物为exe，点击exe启动

# 使用

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa1e5df3682a?w=1819&h=932&f=png&s=108380)

左边是json的输入框以及最后Dart生成的代码，右边是生成的Json类的结构

## 格式化

点击格式化按钮，将json转换为右边可视化的json类结构

## 更多设置

设置会全部自动保存（flutter版本除外，需要手动保存），一次设置终身受益

### 数据类型全方位保护

大家一定会有被服务端坑的时候吧？ 不按规定好了的数据类型传值，导致json整个解析失败。

打开这个开关，就会在获取数据的时候加一层保护，代码如下

```dart
T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  if (value != null) {
    final String valueS = value.toString();
    if (0 is T) {
      return int.tryParse(valueS) as T;
    } else if (0.0 is T) {
      return double.tryParse(valueS) as T;
    } else if ('' is T) {
      return valueS as T;
    } else if (false is T) {
      if (valueS == '0' || valueS == '1') {
        return (valueS == '1') as T;
      }
      return bool.fromEnvironment(value.toString()) as T;
    }
  }
  return null;
}
```

### 数组全方位保护

在循环数组的时候，一个出错，导致json整个解析失败的情况，大家遇到过吧？

打开这个开关，将对每一次循环解析进行保护，代码如下

```dart
void tryCatch(Function f) {
  try {
    f?.call();
  } catch (e, stack) {
    debugPrint("$e");
    debugPrint("$stack");
  }
}
```

### 遍历数组次数

在服务器返回的数据中，有时候数组里面不是每一个item都带有全部的属性，

如果只检查第一个话，会存在属性丢失的情况

你可以通过多次循环来避免丢失属性

选项有1，20，99

99就代表循环全部进行检查

### 属性命名

属性命名规范选项：保持原样，驼峰式命名小驼峰，帕斯卡命名大驼峰，匈牙利命名下划线

[Dart 命名规范](https://dart.dev/guides/language/effective-dart/style)

Dart 官方推荐 驼峰式命名小驼峰

### 属性排序

对属性进行排序

排序选项： 保持原样，升序排列，降序排序

### 添加保护方法

是否添加保护方法。数据类型全方位保护/数组全方位保护 这2个开启的时候会生成方法。第一次使用的时候开启就可以了，你可以方法提出去，后面生成Dart就没有必要每个文件里面都要这2个方法了。

### 文件头部信息

可以在这里添加copyright，improt dart，创建人信息等等，支持[Date yyyy MM-dd]来生成时间，Date后面为日期格式。

比如[Date yyyy MM-dd] 会将你生成Dart代码的时间按照yyyy MM-dd的格式生成对应时间

### 属性访问器类型

点击格式化之后，右边会显示可视化的json类结构，在右边一列，就是属性访问器类型设置

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa22e594ca44?w=1034&h=293&f=png&s=23457)

选项：默认，Final，Get，GetSet

顶部设置修改，下面子项都会修改。你也可以单独对某个属性进行设置。

## 修改json类信息

点击格式化之后，右边会显示可视化的json类结构。

第一列为在json中对应的key

第二列为属性类型/类的名字。如果是类名，会用黄色背景提示

第三列是属性的名字

输入选项如果为空，会报红提示

## 生成Dart

做好设置之后，点击生成Dart按钮，左边就会生成你想要的Dart代码，并且提示“Dart生成成功，已复制到剪切板”，可以直接复制到你的Dart文件里面


是不是很方便很人性化，欢迎Start，Fork，666三连。


最后放上 [Josn To Dart](https://github.com/fluttercandies/JsonToDart)，如果你有什么不明白或者对这个方案有什么改进的地方，请告诉我，欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter 小糖果(QQ群:181398081)

再次邀请，有心为Flutter生态做贡献的小伙伴加入[Flutter Candies](https://github.com/fluttercandies)，一起开心地写bug。


![](https://user-gold-cdn.xitu.io/2019/6/27/16b97c16f525f495?w=350&h=348&f=png&s=93834)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)
