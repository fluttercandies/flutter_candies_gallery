import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

@FFRoute(
  name: 'fluttercandies://demo1',
  routeName: 'demo1',
  description: 'demo1',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class Demo1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Markdown(data:'''## 前言

* 去年的情人节，没有过节的孩纸，悄悄地创建了一个Flutter群。记得开始就我和死鱼(另一个UWP开发)2个人,慢慢地，慢慢地人渐渐多了，认识了越来越多喜欢写`bug`的小伙伴。
![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8a98b2abda1d4ca4bf639d06e28e62b6~tplv-k3u1fbpfcp-zoom-1.image)

* 也许我们中的一些人不是专业出身，有的养过鱼的，有的工地干过，也有的卖东西，但是我们也许都有一个特点，就是真的热爱`0`和`1`。在生活的压力下面，我们依然会利用业余时间研究一些新玩意，也愿意将自己所学所知分享。从创建[Flutter Candies](https://github.com/fluttercandie)到现在，共发布26个packages到[pub.dev](https://pub.flutter-io.cn/publishers/fluttercandies.com/packages)，
[Flutter Candies](https://github.com/fluttercandies)共维护着46个项目。

* 喜欢自己做的事是幸福，能和一群人一起做喜欢的事情是开心的。说不清楚，有时候为了写某个bug，会不知觉地到深夜。不知道什么时候会不喜欢写代码，但喜欢的时候就应该全力以赴。等等，咋熬起了鸡汤...

## 糖果小助手

[大宝](https://github.com/lycstar)周末的时候突然丢了一个开源项目[CandiesBot](https://github.com/fluttercandies/CandiesBot)出来，
项目是基于[QQ 高效率机器人](https://github.com/mamoe/mirai)。
大家玩的不亦乐乎，低调，拉面，保安也迅速加入了战场，各自fork了之后，做出了风格各异的机器人，于是就有了下面4个群助手。

![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d45c8411a1444531bfcb4299ac413ec7~tplv-k3u1fbpfcp-zoom-1.image)

### 糖果小蜜

[低调](https://github.com/CaiJingLong)出品，绝对精品.

作为助手里的头牌，小蜜主要负责管理员相关的功能，工作时间 `007`。

```
以下为机器人使用帮助:
/h 显示本帮助

/muteAll: <y | n>, y对应关灯, n对应开灯, 只能由管理员发起
   别名: /开灯,/关灯

/mute <QQ号> 时长, 单位:分钟
   别名: /小黑屋,/闭嘴,/禁言,/封印,/封,/禁

/unmute <QQ号>
   别名: /解禁,/放出来,/解,/解封

/kick <QQ号>
   别名: /踢,/踢出去,/踢人,/remove,/rm
```

每天熬鸡汤的我，总担心有一天会被别人替代，但是没想到过这一天来的这么快。

* /开灯
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29e2b10f291f45a7a57769287a0531f2~tplv-k3u1fbpfcp-zoom-1.image)

* /关灯
![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/14dcff12387f4b239bac0cb3c33a3ec5~tplv-k3u1fbpfcp-zoom-1.image)

 ### 糖果小宝

[大宝](https://github.com/lycstar)的作品,我发现这些00后总是有一些稀奇古怪的想法，初中，高中，大学的年轻人都好强，真的老了，跟不上了。工作时间 `007`。

   ![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc4028012bae473782a0214f7fcb1e15~tplv-k3u1fbpfcp-zoom-1.image)
* /help 显示本帮助

* /pub 包名
这应该是最实用的功能，群里总是会一边又一边的有人会问：

    1.这个效果怎么做啊？

    2.有没有某某效果的三方组件？

    3.在哪里才能找到？

现在只需要输入命令 `/pub extended_image`，就能获取到该`package`的信息。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/902b6e87b96d45a4a4442fb4a61355b9~tplv-k3u1fbpfcp-zoom-1.image)

* /bing 关键词

不用打开网页，我也能查资料了？

* /music 关键词

别老是分享一些奇怪的歌！

### 糖果小面

听这个名字，应该有人就能猜出来了吧。这是[拉面](https://juejin.im/user/4265760846775533)的作品, 主打的是知心小姐姐(a yi), 属于聊天型的，也会帮助小蜜维持群里的秩序。工作时间 `955`。

![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/71f434d3851748ff9a918d5ccbce345c~tplv-k3u1fbpfcp-zoom-1.image)

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f052a06f7d864018b0a176eddbb5f251~tplv-k3u1fbpfcp-zoom-1.image)

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ccfdad18e75c420ea14c20ca7da4af9d~tplv-k3u1fbpfcp-zoom-1.image)

### 糖果小爷

[保安](https://github.com/mrliuwen)的作品， 放荡不羁的机器人，逗比一个，负责舔狗，劝退等工作。工作时间 `955`。

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee4164658b8b4d2ba36b840017b5022d~tplv-k3u1fbpfcp-zoom-1.image)

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0383f1dc50f44364a843f92f2dd3021e~tplv-k3u1fbpfcp-zoom-1.image)

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1abca8e6bf2d4e81aa0bedba79e41f61~tplv-k3u1fbpfcp-zoom-1.image)

### Action 发布 Pub

由[Alex](https://github.com/AlexV525)分享,对对对，就是那个 Flutter Team里面的那个。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4a4255d1db61454882f65fe31d83e2e2~tplv-k3u1fbpfcp-zoom-1.image)

![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/54520ca43e2a48baa3dfd5152089df74~tplv-k3u1fbpfcp-zoom-1.image)

这其实是一个 Github Action，帮助你在任何有网络的地方，能够快速的发布更新自己的package到pub。

#### 增加pub_publish.yml

在你的Flutter/Dart项目下面添加，路径参考[pub_publish.yml](https://github.com/fluttercandies/extended_image/blob/master/.github/workflows/pub_publish.yml)

``` yml
name: Pub Publish plugin

on: workflow_dispatch

jobs:
  publish:

    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Publish
        uses: sakebook/actions-flutter-pub-publisher@v1.3.0
        with:
          credential: \${{ secrets.CREDENTIAL_JSON }}
          flutter_package: true
          skip_test: true
          dry_run: false
```

#### 找到你的证书

在你的本地环境中，你如果已经成功发布一次 `package` 到 `pub.dev`, 那么在路径

* Windows：  `C:\Users\用户名\AppData\Roaming\Pub\Cache\credentials.json`
* Mac： `~/.pub-cache/credentials.json`

中会保存你发布的一些信息。

#### 在Github中设置证书

* 打开你项目的Setting
将credentials.json里面的内容复制一个新的secret中。
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df56127efa854eb08b3555c03aca8492~tplv-k3u1fbpfcp-zoom-1.image)


#### 运行action

* Actions=》Pub Publish plugin =》Run workflow 下拉 =》 选择Branch =》 Run workflow
![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8bfb1f64e6384dfc991dc2e9b3d0a703~tplv-k3u1fbpfcp-zoom-1.image)

* 执行中
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b88e886e26fc45398489704409c03747~tplv-k3u1fbpfcp-zoom-1.image)

* 发生错误的时候，你可以点击错误的task，打开查看错误信息

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c488daf057fd4e2a8f6b0de8b73f1f2e~tplv-k3u1fbpfcp-zoom-1.image)
![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95e48c3f3fae4c2583948a14889653e7~tplv-k3u1fbpfcp-zoom-1.image)

#### Github Page

如果你在项目里面部署了GithubPage，那么建议把web的文件放到单独的Branch中，不然每次打包发布都会把web文件也一起打包发布。

![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36d6e80da1cd443bbe4725fd4597393d~tplv-k3u1fbpfcp-zoom-1.image)

## 结语

他们说有彩蛋，彩蛋是不可能有的，这一辈子都不可能有彩蛋。

![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/906dc3f0cf014098b18aa5335c115a63~tplv-k3u1fbpfcp-zoom-1.image)

很开心能和一群有趣的小伙伴一起学习Flutter，一起写bug。就像大学5人开黑一样，希望自己能够一直写下去。感谢群里热心的成员，因为你们圈子才越来越好，因为你们的付出才有更多人愿意付出。

欢迎加入[Flutter Candies](https://github.com/fluttercandies)，一起生产可爱的Flutter小糖果[![](https://user-gold-cdn.xitu.io/2019/10/27/16e0ca3f1a736f0e?w=90&h=22&f=png&s=1827)QQ群:181398081](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

最最后放上[Flutter Candies](https://github.com/fluttercandies)全家桶，真香。

![](https://user-gold-cdn.xitu.io/2019/5/29/16b02e0775f4af97?w=1920&h=1920&f=png&s=131155)



''');
  }
}

