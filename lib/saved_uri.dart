import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

List<Info> saveds = [];
List<String> clips = [];

StreamController<String> sctr = StreamController.broadcast(
  onListen: () => print("stream controller listened"),
  onCancel: () => print("stream controller canceled")
);

const Map<String, String> PLATFORMS = {
  'youtube.com' : "유튜브",
  'instagram.com': "인스타",
  'naver.com' : '네이버',
  '' : "출처 불명"
};
const Map<String, IconData> LOGOS = {
  "유튜브" : CustomIcons.youtube,
  "인스타" : CustomIcons.instagram,
  "네이버" : CustomIcons.naver,
  "출처 불명" : Icons.question_mark
};

class CustomIcons {
  CustomIcons._();

  static const _kFontFam = 'CustomIcons';
  static const String? _kFontPkg = null;

  static const IconData naver = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData youtube = IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData instagram = IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

class Info {
  final String _uri;
  final List<String> _tags;
  late String _platform;
  late IconData _logo;

  Info(this._uri, this._tags) {
    final keys = PLATFORMS.keys.toList();
    for (int i=0 ; i < keys.length ; i++) {
      if (this._uri.contains(keys[i])) {
        this._platform = PLATFORMS[keys[i]]!;
        this._logo = LOGOS[this._platform]!;
        break;
      }
    }
  }

  factory Info.fromJson(Map<String, dynamic> data) {
    String _uri = data['uri'];
    List<String> _tags = (data['tags'] as List).map((e) => e as String).toList();
    return Info(_uri, _tags);
  }

  String get uri => _uri;
  List<String> get tags => _tags;
  String get platform => _platform;
  IconData get logo => _logo;
}

class JsonStorage {
  final String fname;
  JsonStorage({required this.fname});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final file = File('$path/$fname.json');
    if (await file.exists() == false)
      await file.create();
    return file;
  }

  Future<String> readJson() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    }
    catch (e) {
      print("!!!!! error !!!!!");
      print(e);
      return "error";
    }
  }

  Future<File> writeJson(String s) async {
    final file = await _localFile;
    return file.writeAsString(s);
  }
}