import 'dart:convert';
import 'dart:async';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:share_plus/share_plus.dart';

import 'package:share_box/card.dart';
import 'package:share_box/saved_uri.dart';
import 'package:sliver_tools/sliver_tools.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  final JsonStorage info_storage = JsonStorage(fname: "info");
  final JsonStorage tag_storage = JsonStorage(fname: 'tag');
  late StreamSubscription _intentDataStreamSubscription;
  List<String> selected_tags = [];
  String? prev;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream()
        .listen((List<SharedFile> value) async {
          if (value.isNotEmpty) {
            final uri = value[0].value ?? '';
            showDialog(
                context: context,
                builder: (ctx) => DetailCard(create: true, info: Info(uri, []))
            );
            Future<void>.delayed(Duration(seconds: 1))
                .then((_) => value.clear());
          }
        },
        onError: (err) => print("getIntentDataStream error: $err")
    );

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      if (value.isNotEmpty) {
        final uri = value[0].value ?? '';
        setState(() {
          showDialog(
              context: context,
              builder: (ctx) => DetailCard(create: true, info: Info(uri, []))
          );
          Future<void>.delayed(Duration(seconds: 1))
              .then((_) => value.clear());
        });
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadInfoAndTag(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              padding: EdgeInsets.only(top: 20),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(color: Colors.black),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            var (r1, r2) = snapshot.data ?? (<Info>[], <String>[]);
            List<Info> temp = saveds = r1;
            clips = r2;
            return StreamBuilder(
              stream: sctr.stream,
              builder: (context, snapshot2) {
                if (snapshot2.hasData) {
                  /// reset tags list
                  if (snapshot2.data![0] == '>') {
                    saveTags();
                    selected_tags.clear();
                    temp = saveds;
                  }
                  /// search by tag
                  if (snapshot2.data![0] == '*') {
                    temp = selected_tags.isEmpty ? saveds : filtering();
                  }
                  /// item add
                  else if (snapshot2.data![0] == '+' && snapshot2.data != prev) {
                    List<String> splitted = snapshot2.data!.substring(1).split(',');
                    saveds.add(Info(splitted[0], splitted.sublist(1)));
                    saveds = [...{...saveds}];
                    saveInfo();
                    selected_tags.clear();
                    temp = saveds;
                    print(saveds.length);
                    prev = snapshot2.data;
                  }
                  /// item sub
                  else if (snapshot2.data![0] == '-' && snapshot2.data != prev) {
                    saveds.removeWhere((e) => snapshot2.data!.substring(1) == e.uri);
                    saveInfo();
                    temp = selected_tags.isEmpty ? saveds : filtering();
                    prev = snapshot2.data;
                  }
                }
                return CustomScrollView(slivers: [
                  MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                      /// <Tag> header
                      SliverPinnedHeader(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 11),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // text
                                Text("Tag", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                // selected tags
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 90,
                                  height: 24,
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      itemCount: selected_tags.length,
                                      itemBuilder: (context, index) => Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        child: Row(children: [
                                          Text(selected_tags[index], style: TextStyle(fontSize: 10)),
                                          SizedBox(width: 2),
                                          GestureDetector(
                                            onTap: () {
                                              selected_tags.removeAt(index);
                                              sctr.add('*');
                                            },
                                            behavior: HitTestBehavior.translucent,
                                            child: Icon(Icons.close, size: 10),
                                          )
                                        ]),
                                      ),
                                      separatorBuilder: (context, index) => SizedBox(width: 6)
                                  ),
                                ),
                                // cancel button
                                GestureDetector(
                                  onTap: () {
                                    selected_tags.clear();
                                    sctr.add('*');
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.cancel, size: 16)
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                      /// <Tag> body
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: clips.isEmpty ? null : ChipsChoice<String>.multiple(
                                padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                                value: selected_tags,
                                onChanged: (val) {
                                  selected_tags = val;
                                  sctr.add('*');
                                },
                                choiceItems: C2Choice.listFrom<String, String>(
                                  source: clips,
                                  value: (i, v) => v,
                                  label: (i, v) => v,
                                ),
                                wrapCrossAlignment: WrapCrossAlignment.start,
                                wrapped: true,
                              ),
                            ),
                            TextButton(
                              onPressed: () => showDialog(
                                  context: context, builder: (ctx) => TagCard()),
                              child: Text("카테고리 관리",
                                style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                              ),
                            )
                          ]
                      ),
                      /// <Sharing> body
                      if (temp.isEmpty)
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          alignment: Alignment.topCenter,
                          child: Text("데이터 없음"),
                        )
                      else
                        SliverList.builder(
                          itemCount: temp.length + 1,
                          itemBuilder: (context, index) {
                            if (index < temp.length)
                              return Item(info: temp[index % temp.length]);
                            else return SizedBox(height: 80);
                          },
                        )
                    ],
                  ),
                ]);
              },
            );
        }
      },
    );
  }

  List<Info> filtering() {
    List<Info> result = [];
    saveds.forEach((info) {
      for (int i=0 ; i < info.tags.length ; i++)
        if (selected_tags.contains(info.tags[i])) {
          result.add(info);
          break;
        }
    });
    return result;
  }

  Future<void> saveInfo() async {
    Iterable<Map<String, dynamic>> raw_data = await saveds.map((e) => {
      'uri': e.uri, 'tags': e.tags
    });
    await info_storage.writeJson(jsonEncode(raw_data.toList()));
    print("저장");
  }

  Future<void> saveTags() async {
    tag_storage.writeJson(jsonEncode(clips));
  }

  Future<(List<Info>, List<String>)> loadInfoAndTag() async {
    String reading = await info_storage.readJson();
    List<dynamic> raw = jsonDecode(reading);
    List<Info> infos = raw.map((e) => Info.fromJson(e)).toList();
    reading = await tag_storage.readJson();
    List<String> tags = (jsonDecode(reading) as List)
        .map((e) => e as String).toList();
    return Future(() => (infos, tags));
  }
}

class Item extends StatelessWidget {
  Item({super.key, required this.info});

  final Info info;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("아이템 터치");
        showDialog(
          context: context,
          builder: (ctx) => DetailCard(create: false, info: info)
        );
      },
      onLongPress: () => onCopy(context, info.uri),
      child: Container(
        height: 100,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: LayoutBuilder(builder: (context, constrains) =>
            Stack(children: [
              /// platfrom
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: constrains.maxHeight,
                  height: constrains.maxHeight,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(2, 0),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(info.logo, size: 48),
                ),
              ),
              // title
              Positioned(
                left: 118,
                top: 11,
                child: Text(
                  "${info.platform}의 게시물",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // tags
              Positioned(
                top: 36,
                left: 118,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: info.tags.map((e) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(100)
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: TextStyle(fontSize: 10, height: 0)),
                      );
                    }).toList()
                ),
              ),
              /// icon buttons
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(children: [
                    /// copy uri
                    GestureDetector(
                      onTap: () => onCopy(context, info.uri),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.copy, size: 24),
                      ),
                    ),
                    /// share sheet
                    GestureDetector(
                      onTap: () => onShare(info.uri),
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.share, size: 24)
                      ),
                    ),
                    /// remove item
                    GestureDetector(
                      onTap: () => onRemove(context, info.uri),
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.delete, size: 24)
                      ),
                    ),
                  ])
              ),
            ])
        )
      ),
    );
  }

  Future<void> onCopy(BuildContext context, String txt) async {
    print("복사");
    await Clipboard.setData(ClipboardData(text: txt))
        .then((_) {
      BuildContext parent_ctx = context.findAncestorStateOfType()!.context;
      ScaffoldMessenger.of(parent_ctx).showSnackBar(
          SnackBar(content: Text("복사 성공!")));
    });
  }

  Future<void> onShare(String txt) async {
    print("공유");
    await Share.share(txt);
  }

  void onRemove(BuildContext context, String txt) {
    print("삭제");
    sctr.add('-$txt');
    // showDialog(
    //   context: context.findAncestorStateOfType()!.context,
    //   builder: (ctx) => AlertDialog(
    //
    //   )
    // );
  }
}