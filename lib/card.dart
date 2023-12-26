import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:share_box/saved_uri.dart';
import 'package:textfield_tags/textfield_tags.dart';

class DetailCard extends StatefulWidget {
  const DetailCard({super.key, required this.create, this.info});

  final bool create;
  final Info? info;

  @override
  State<DetailCard> createState() => _DetailCardState();
}
class _DetailCardState extends State<DetailCard> {
  final TextEditingController txtedit_ctr = TextEditingController();
  final TextfieldTagsController tft_ctr = TextfieldTagsController();
  late String cur_uri;
  late List<String> cur_tags;
  late bool edit;

  @override
  void initState() {
    super.initState();
    if (widget.info == null) {
      cur_uri = txtedit_ctr.text = "";
      cur_tags = [];
      edit = true;
    } else if (widget.create) {
      cur_uri = txtedit_ctr.text = widget.info!.uri;
      cur_tags = [];
      edit = true;
    }
    else {
      cur_uri = txtedit_ctr.text = widget.info!.uri;
      cur_tags = widget.info!.tags;
      edit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media_size = MediaQuery.of(context).size;
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: Container(
          margin: EdgeInsets.fromLTRB(
              media_size.width * 0.1,
              media_size.height * 0.1,
              media_size.width * 0.1,
              media_size.height * 0.2
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          child: LayoutBuilder(builder: (context, constrains) {
            if (edit)
              return Material(
                color: Colors.transparent,
                child: Stack(children: [
                  Positioned(
                    top: 4,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.info == null)
                          Navigator.pop(context);
                        else setState(() => edit = false);
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 6,
                    child: GestureDetector(
                      onTap: onSave,
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.data_saver_on, size: 30),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: constrains.maxWidth * 0.14,
                  //   width: constrains.maxWidth,
                  //   height: constrains.maxWidth,
                  //   child: Container(
                  //       margin: EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //           color: Colors.grey,
                  //           borderRadius: BorderRadius.circular(10)
                  //       ),
                  //       alignment: Alignment.center,
                  //       child: Text("아직 지원되지 않는 기능입니다")
                  //   ),
                  // ),
                  Positioned(
                    top: constrains.maxWidth * 0.15,
                    width: constrains.maxWidth,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: txtedit_ctr,
                                decoration: InputDecoration(labelText: "URI"),
                              ),
                              Autocomplete<String>(
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 4.0),
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: 200,
                                            maxWidth: constrains.maxWidth * 0.85
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final dynamic option = options.elementAt(index);
                                            return TextButton(
                                              onPressed: () => onSelected(option),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Text(option,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: Color.fromARGB(255, 74, 137, 92)),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return const Iterable<String>.empty();
                                  }
                                  return clips.where((String option) {
                                    return option.contains(textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (String selectedTag) {
                                  tft_ctr.addTag = selectedTag;
                                },
                                fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
                                  return TextFieldTags(
                                    textEditingController: ttec,
                                    focusNode: tfn,
                                    textfieldTagsController: tft_ctr,
                                    initialTags: cur_tags,
                                    textSeparators: const [' ', ',', '\n'],
                                    letterCase: LetterCase.normal,
                                    validator: (String tag) {
                                      if (clips.contains(tag) == false) {
                                        return 'Not exsisted';
                                      } else if (tft_ctr.getTags!.contains(tag)) {
                                        return 'you already entered that';
                                      } else if (tft_ctr.getTags!.length == 3) {
                                        return 'you can enter max 3 tag';
                                      } else return null;
                                    },
                                    inputfieldBuilder:
                                        (context, tec, fn, error, onChanged, onSubmitted) {
                                      return ((context, sc, tags, onTagDelete) {
                                        return TextField(
                                          controller: tec,
                                          focusNode: fn,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.deepPurpleAccent),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            disabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            enabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.deepPurpleAccent),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            focusedBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 3, color: Colors.deepPurple),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            errorBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.deepPurple),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            focusedErrorBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 3, color: Colors.deepPurple),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            hintText: tft_ctr.hasTags ? '' : "Tag",
                                            errorText: error,
                                            prefixIconConstraints: BoxConstraints(
                                                maxWidth: media_size.width * 0.74),
                                            prefixIcon: tags.isNotEmpty
                                                ? SingleChildScrollView(
                                              controller: sc,
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  children: tags.map((String tag) {
                                                    return Container(
                                                      decoration: const BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                        color: Colors.deepPurpleAccent,
                                                      ),
                                                      margin: const EdgeInsets.only(right: 10.0),
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(tag, style: TextStyle(color: Colors.white)),
                                                          const SizedBox(width: 4.0),
                                                          InkWell(
                                                            child: const Icon(
                                                              Icons.cancel,
                                                              size: 14.0,
                                                              color: Color.fromARGB(255, 233, 233, 233),
                                                            ),
                                                            onTap: () => onTagDelete(tag),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  }).toList()),
                                            )
                                                : null,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8)
                                          ),
                                          onChanged: onChanged,
                                          onSubmitted: onSubmitted,
                                        );
                                      });
                                    },
                                  );
                                },
                              )
                            ]
                        )
                    ),
                  ),
                ]),
              );
            else
              return Material(
                color: Colors.transparent,
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: constrains.maxWidth * 0.14,
                      height: constrains.maxWidth * 0.14,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          )
                      ),
                      alignment: Alignment.center,
                      child: Icon(widget.info!.logo),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        print("수정");
                        setState(() => edit = true);
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.edit, size: 30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: constrains.maxWidth * 0.14,
                    width: constrains.maxWidth,
                    height: constrains.maxWidth,
                    child: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        alignment: Alignment.center,
                        child: Text("아직 지원되지 않는 기능입니다")
                    ),
                  ),
                  Positioned(
                    top: constrains.maxWidth * 1.15,
                    width: constrains.maxWidth,
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cur_uri,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Wrap(
                                  spacing: 10,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.start,
                                  children: cur_tags
                                      .map((tag) => Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(tag, style: TextStyle(fontSize: 14))
                                  )).toList()
                              ),
                            ]
                        )
                    ),
                  ),
                  Positioned(
                      bottom: 14,
                      right: 14,
                      child: Row(children: [
                        GestureDetector(
                          onTap: () => onCopy(context, cur_uri),
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.copy, size: 24),
                          ),
                        ),
                        GestureDetector(
                          onTap: onShare,
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.share, size: 24)
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.delete, size: 24)
                          ),
                        ),
                      ])
                  ),
                ]),
              );
          })
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

  Future<void> onShare() async {
    print("공유");
    await Share.share(cur_uri);
  }

  void onRemove() {
    print("삭제");
    sctr.add("-$cur_uri");
    Navigator.pop(context);
  }

  void onSave() {
    print("저장");
    String event = "+${cur_uri = txtedit_ctr.text}";
    (cur_tags = tft_ctr.getTags ?? []).forEach((e) => event += ',$e');
    if (widget.info == null || widget.create) {
      sctr.add(event);
      Navigator.pop(context);
    }
    else {
      setState(() {
        saveds.removeWhere((e) => e.uri == widget.info!.uri);
        sctr.add(event);
        edit = false;
      });
    }
  }
}

class TagCard extends StatefulWidget {
  const TagCard({super.key});

  @override
  State<TagCard> createState() => _TagCardState();
}
class _TagCardState extends State<TagCard> {
  final TextEditingController edit_ctr = TextEditingController();
  List<String> temp_clips = clips;

  @override
  Widget build(BuildContext context) {
    final media_size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.fromLTRB(
            media_size.width * 0.1,
            media_size.height * 0.1,
            media_size.width * 0.1,
            media_size.height * 0.2
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 13
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// back / save
            Flexible(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, size: 30),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sctr.add('>');
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.data_saver_on, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            /// tags
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 11),
                alignment: Alignment.centerLeft,
                child: Text("Tags", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              ),
            ),
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(11, 0, 11, 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: temp_clips
                        .map((tag) => Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text(tag, style: TextStyle(fontSize: 14)),
                                SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    temp_clips.remove(tag);
                                  }),
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close, size: 12)
                                  ),
                                )
                              ]
                          ),
                        ))
                        .toList()
                  ),
                ),
              ),
            ),
            /// add tag
            Flexible(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 200,
                        child: TextField(controller: edit_ctr)
                      ),
                    ),
                    IgnorePointer(
                      ignoring: edit_ctr.text.isEmpty,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (temp_clips.contains(edit_ctr.text))
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("이미 존재함")));
                            else {
                              setState(() {
                                temp_clips.add(edit_ctr.text);
                                edit_ctr.clear();
                              });
                            }
                          });
                        },
                        child: Text("추가"),
                      ),
                    )
                  ],
                )
            )
          ],
        )
    );
  }
}
