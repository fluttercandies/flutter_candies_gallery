## [JsonToDart](https://github.com/fluttercandies/JsonToDart) 相关文章

- [Flutter 功能最全的JsonToDart工具(桌面Web海陆空支持)](https://juejin.im/post/6844903875833495566)
- [Flutter JsonToDart Mac版 lei了，真的不mark吗](https://juejin.im/post/6844903882330488845)
- [Flutter JsonToDart 工具](https://juejin.im/post/6844904138032037895)

**2020-05-04 更新UWP版本增加是否Dart格式化的开关(使用网络格式化Dart有点慢)**

做Flutter快1年半了，从开始的就是干
![](https://user-gold-cdn.xitu.io/2020/4/23/171a4a44fb29f5db?w=612&h=408&f=jpeg&s=20393)

到现在写代码也会注意规范，性能，注释，各种细节。一个好的工具能提高我们的工作效率，

这次更新 [JsonToDart](https://github.com/fluttercandies/JsonToDart)主要是以下考虑:

* 之前开发的时候就是为了方便开发，快速生成dart代码，也没有太注意dart的代码规范。
* 之前的版本因为Flutter桌面的不完善，是通过go-flutter来最终生成产物的。Flutter sdk版本已经来到1.18，桌面功能进一步完善，是时候重新编译来一波了
* Github 在国内速度实在太慢，于是考虑安装包和网页版本移动到Gitee上面供大家使用

## 下载安装

* [UWP 微软商店](https://www.microsoft.com/store/apps/9NBRW9451QSR) 我这次放微软商店了，Windows10的窗户小伙伴建议使用这个，如果更新也是自动的。
点击链接或者打开微软商店搜索`JsonToDart`。
![](https://user-gold-cdn.xitu.io/2020/4/23/171a4fe10a0f47b8?w=1920&h=1017&f=png&s=133506)

* [WPF for Windows](https://gitee.com/zmtzawqlp/JsonToDart/releases) 为Windows7，8 的窗户用户准备了WPF版本的安装包

* [UWP for Windows10](https://gitee.com/zmtzawqlp/JsonToDart/releases) 如果微软商店大姨妈了，你可以直接在这里下载安装包，安装方法可以查看之前的文章

* [Flutter for Macos](https://gitee.com/zmtzawqlp/JsonToDart/releases) Flutter一波带走全平台，真香，为马克儿用户提供的app，直接拖到应用程序里面就好了

* [Flutter for Web](https://zmtzawqlp.gitee.io/jsontodartflutterweb) 懒得安装？？ 好嘛，这里还有网页版本，不过建议还是用其他版本，js 没法区分double 和 int的问题，如果一定要用，建议到时候开启数据类型全方位保护，具体请看后面

## 使用


![](https://user-gold-cdn.xitu.io/2020/4/23/171a503cc73bdb59?w=1915&h=1017&f=png&s=150786)

左边是json的输入框以及最后Dart生成的代码，右边是生成的Json类的结构

### 格式化

点击格式化按钮，将json转换为右边可视化的json类结构

### 更多设置

设置会全部自动保存，Flutter版本除外，需要手动保存,我还没有发现应用退出的时机，Flutter版本记得点击`保存配置`,手动保存一下.

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

[Dart 命名规范](https://dart.dev/guides/language/effective-dart/style)

属性命名规范选项：

* 保持原样
* 驼峰式命名小驼峰 josnToDart
* 帕斯卡命名大驼峰 JsonToDart
* 匈牙利命名下划线 json_to_dart

Dart 官方推荐 驼峰式命名小驼峰

### 属性排序

对属性进行排序

排序选项： 
* 保持原样
* 升序排列
* 降序排序

### 添加保护方法

是否添加保护方法。数据类型全方位保护/数组全方位保护 这2个开启的时候会生成方法。
第一次使用的时候开启就可以了，你可以方法提出去放一个dart文件里面(并且在文件头中加入引用)。
后面生成的时候就没必要再开启了。

### 文件头部信息

可以在这里添加copyright，improt dart，创建人信息等等，支持[Date yyyy MM-dd]来生成时间，Date后面为日期格式。

比如[Date yyyy MM-dd] 会将你生成Dart代码的时间按照yyyy MM-dd的格式生成对应时间

### 属性访问器类型

点击格式化之后，右边会显示可视化的json类结构，在右边一列，就是属性访问器类型设置

![](https://user-gold-cdn.xitu.io/2019/7/8/16bcfa22e594ca44?w=1034&h=293&f=png&s=23457)

选项：
* 默认
* Final
* Get
* GetSet

顶部设置修改，下面子项都会修改。你也可以单独对某个属性进行设置。

### 修改json类信息

![](https://user-gold-cdn.xitu.io/2020/4/23/171a5083bba65def?w=1117&h=957&f=png&s=79905)

点击格式化之后，右边会显示可视化的json类结构。

第一列为在json中对应的key

第二列为属性类型/类的名字。如果是类名，会用黄色背景提示

第三列是属性的名字，输入选项如果为空，会报红提示

第四列是属性的访问器类型

### 生成Dart

做好设置之后，点击生成Dart按钮，左边就会生成你想要的Dart代码，并且提示“Dart生成成功，已复制到剪切板”，可以直接复制到你的Dart文件里面

## 举个栗子

![](https://user-gold-cdn.xitu.io/2020/4/23/171a51b0763a63eb?w=358&h=318&f=png&s=132448)

比如说业务中，`Person`，有名字年龄
``` dart
import 'dart:convert';
import 'util.dart';
part 'person_part.dart';

class Person {
  Person({
    this.age,
    this.name,
  });

  factory Person.fromJson(Map<String, dynamic> jsonRes) =>
      Person(age: asT<int>(jsonRes['age']), name: asT<String>(jsonRes['name']));

  final int age;
  final String name;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'age': age,
        'name': name,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
```
现在前端有业务逻辑，需要知道这个人是小孩子，年轻人还是老人。那么我们应该怎么做？直接写这个类里面？

当然可以，
但是如果服务器以后变更这个数据模型，那么我们用工具直接生成代码复制，那我们的业务代码是不是就会丢掉？

幸运的是

dart 为我们提供了扩展 `extension`，你需要

* 设置dart sdk >=2.6
``` dart
environment:
  sdk: '>=2.6.0 <3.0.0'
```
* Flutter项目根目录创建一个analysis_options.yaml文件，然后添加以下内容到文件中。
``` dart
analyzer:
    enable-experiment:
        - extension-methods
```
然后你可以这样做。
``` dart
part of 'person.dart';

enum AgeType {
  baby,
  youth,
  old,
}

extension PersonE on Person {
  AgeType get ageType {
    if (age < 5) {
      return AgeType.baby;
    } else if (age < 50) {
      return AgeType.youth;
    }
    return AgeType.old;
  }

}
```
这样任你Person元数据模型修改的时候，原本写的业务逻辑也不会需要重写，只需要再次运行工具即可。

## 不足

* 对于一些需要修改属性的场景，用`mixin`混入或者干脆把这个属性设置为可写，还是没法摆脱
``` dart
mixin PersonMixin  {
   int currentAge;
}
```
* 在解析json的时候根据不同情况解析不同的数据模型，就是经常大家问的，支不支持泛型。。话说。这个服务端同一个接口，返回不同的数据类型模型，不知道是业界常态还是。。
![](https://user-gold-cdn.xitu.io/2020/4/23/171a66ebde74206c?w=69&h=69&f=jpeg&s=1318)

最惨就是这些代码写元数据模型里面了，下一次更新的时候只好手写。简单的模型还好，大的模型千把行，真的是醉了。
![](https://user-gold-cdn.xitu.io/2020/4/23/171a683068d54460?w=87&h=69&f=png&s=961)

* 可惜的是dart并没有支持[`partial`](https://github.com/dart-lang/language/issues/252)将类进行拆分，不得不说还是我软牛逼，C#牛逼。不知道dart什么时候会支持。


## 打包的过程

整个打包时在Flutter 1.18，也记录一下过程。

### Flutter for Windows 

* 在windows机器上面用vscode打开项目，删掉windows目录，执行`flutter create .` 将重新生成windows文件夹(以前只能手动去官方复制)

* Flutter也是与时俱进啊，要求Visual Studio 2019
![](https://user-gold-cdn.xitu.io/2020/4/19/17191abb7cdef4ff?w=1281&h=361&f=jpeg&s=135669)

* 执行`flutter build windows`,执行完毕之后将在build/windows/下面找到打包出来的exe

支持复制粘贴全选这些快捷键了，go-flutter可以不用了。唯一的问题是我发现粘贴的时候会在前面加上一个乱码。

* 悄悄说下，Flutter for UWP 应该快来了，不要问为什么，反正我就是知道。

### Flutter for Macos

* 在mac机器上面用vscode打开项目，删掉macos目录，执行`flutter create .` 将重新生成macos文件夹,mac是官方支持最好的桌面端，无大问题。

* 执行`flutter build macos`,执行完毕之后将在build/macos/下面找到打包出来的app

* 这里讲一下怎么修改app的图标和名字
1.图标在这里，用自己的图标替换掉
![](https://user-gold-cdn.xitu.io/2020/4/22/171a0a7e9048a9b1?w=660&h=718&f=png&s=64602)

2.默认app名字是Flutter，用xcode打开runner.xcodeproj，在`Build Settings`选项中搜索`product name`修改即可，
![](https://user-gold-cdn.xitu.io/2020/4/22/171a0a8a8623f1a5?w=1338&h=718&f=png&s=80283)

### Flutter for Web

* 用vscode打开项目，删掉web目录，执行`flutter create .` 将重新生成web文件夹，注意我index.html里面有引用一个js，用来保存设置的

* 执行`flutter build web`,执行完毕之后将在build/web/下面找到打包出来的文件

## 格式化Dart代码

之前一直没有做这个事情，就是生成的代码，我没有做格式化，我想的是你可以复制到项目里面自己format。但是做，就要做的漂亮，完美。下面我分享下已知的几种格式化方法:

#### 使用终端格式化Dart文件

这是做注解路由(
ff_annotation_route)的时候，低调大佬pr的,最终调用终端执行`flutter format xxx.dart`.

``` dart
Future<void> formatFile(File file) async {
  if (file == null) {
    return;
  }

  if (!file.existsSync()) {
    print(red.wrap('format error: ${file?.absolute?.path} doesn\'t exist\n'));
    return;
  }

  processRunSync(
    executable: 'flutter',
    arguments: 'format ${file?.absolute?.path}',
    runInShell: true,
  );
}

void processRunSync({
  String executable,
  String arguments,
  bool runInShell = false,
}) {
  final ProcessResult result = Process.runSync(
    executable,
    arguments.split(' '),
    runInShell: runInShell,
  );
  if (result.exitCode != 0) {
    throw Exception(result.stderr);
  }
  print('${result.stdout}');
}
```

#### 使用网络请求格式化Dart文件

由于做UWP的时候没法调用终端，所以我在群里问了下有没有其他方式。果然群众是牛逼的，[保洁大佬](https://juejin.im/user/3368559356427950)发现了一个用网络请求做dart格式化的方法。他跑去抓[DartPad](https://dartpad.dartlang.org/),不亏是前端大佬。

请求地址
* 国内`https://dart-services.dartpad.cn/api/dartservices/v2/format`
* 国外`https://dart-services.appspot.com/api/dartservices/v2/format`
* 使用post请求json `{"source","dart代码"}`,返回`{"newstring","格式化之后的dart代码"}`
    
#### 使用[Dart Style](https://github.com/dart-lang/dart_style)

在我写好UWP的dart 格式化的时候，[保洁大佬](https://juejin.im/user/3368559356427950)又丢了一个链接，可以直接用[Dart Style](https://github.com/dart-lang/dart_style)来做format。

2行代码，太简单了！有一群小伙伴真好。。
``` dart
final DartFormatter formatter = DartFormatter();
result = formatter.format(result);
```

## Github 太慢

最近使用github实在是太慢了，其实低调大佬很早就告诉我一个[方法](https://www.kikt.top/posts/other/github-clone-slow/)，就是把Github的库同步到gitee上面，然后再从gitee上面下载，我一直懒没有尝试，最近实在受不了，试了一下，真香！

* 从github clone flutter仓库
![](https://user-gold-cdn.xitu.io/2020/4/25/171b0347ad1e8347?w=880&h=440&f=png&s=20932)
* 从gitee  clone flutter仓库
![](https://user-gold-cdn.xitu.io/2020/4/25/171b03692e3b58a0?w=888&h=449&f=png&s=29788)

### 注册，直接用github账号登录就好了
![](https://user-gold-cdn.xitu.io/2020/4/25/171b176c4ce05092?w=1447&h=938&f=png&s=234411)

### 新建一个仓库

![](https://user-gold-cdn.xitu.io/2020/4/25/171b178123b0b45e?w=1532&h=483&f=png&s=77311)

### 拖动到最下面，导入已有仓库
![](https://user-gold-cdn.xitu.io/2020/4/25/171b179c37539b39?w=1406&h=782&f=png&s=71556)

### 输入github的仓库地址，比如这里是flutter

![](https://user-gold-cdn.xitu.io/2020/4/25/171b17ad88955cf3?w=1179&h=447&f=png&s=41080)

### 等待一分钟(很快)，仓库创建完毕

![](https://user-gold-cdn.xitu.io/2020/4/25/171b17c24d447b98?w=1629&h=761&f=png&s=127927)

* clone到本地即可

![](https://user-gold-cdn.xitu.io/2020/4/25/171b17ccdce68d5c?w=572&h=300&f=png&s=29301)

* 同步github的仓库，仓库名字右边有一个刷新按钮，可以把github的仓库同步过来

![](https://user-gold-cdn.xitu.io/2020/4/25/171b035073f31c53?w=931&h=113&f=png&s=15355)

* 本地修改代码更新到github

终端中输入 `git remote add github https://github.com/flutter/flutter`

修改代码commit之后输入 `git push github`, 完美！

* 以后遇到难以下载的github仓库一定记得用这个办法，大大提高效率。

## 结语

要不是因为想偷懒，人类就不会发明工具。不是因为制造工具，也不会在这个过程中学习到更多。欢迎加入[Flutter Candies](https://github.com/fluttercandies)成为工具人。 (QQ群:181398081)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)



