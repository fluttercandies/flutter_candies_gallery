import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_gallery/model/candy.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_routes.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Custom flutter candies(widgets) for you to build flutter app easily, enjoy it.',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: WaterfallFlow.builder(
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (BuildContext c, int index) {
                final CandyChef candyChef = CandyChiefs()[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        Routes.fluttercandiesCandyChefPage,
                        arguments: <String, dynamic>{
                          'candyChef': candyChef,
                        });
                  },
                  child: Card(
                    elevation: 8,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                tag: candyChef.name,
                                child: ExtendedImage.asset(
                                  candyChef.avatar,
                                  shape: BoxShape.circle,
                                  width: 60,
                                  height: 60,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Text(candyChef.name),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder<String>(
                            builder: (BuildContext c, AsyncSnapshot<String> d) {
                              if (!d.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  ),
                                );
                              }
                              final String t = d.data.split('\n').first;

                              return MarkdownWidget(
                                data: t,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                styleConfig: StyleConfig(pConfig: PConfig(
                                    //linkStyle: TextStyle(...),
                                    onLinkTap: (String url) {
                                  launch(url);
                                })),
                              );
                            },
                            future: candyChef.getIntroductionContent(),
                            initialData: candyChef.content,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: CandyChiefs().length,
            ),
          ),
        )
      ],
    );
  }
}
