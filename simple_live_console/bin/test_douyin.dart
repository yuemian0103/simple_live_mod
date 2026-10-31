import 'dart:convert';
import 'dart:io';
import 'package:simple_live_core/simple_live_core.dart';

void main() async {
  try {
    stdout.encoding = utf8;
  } catch (_) {}
  CoreLog.enableLog = true;
  var site = DouyinSite();
  stdout.writeln('== 获取抖音推荐直播间 ==');
  var recommend = await site.getRecommendRooms();
  if (recommend.items.isEmpty) {
    stdout.writeln('!! 推荐列表为空，接口可能被风控');
    exit(1);
  }
  for (var r in recommend.items.take(3)) {
    stdout.writeln('${r.roomId} | ${r.userName} | ${r.title}');
  }
  var room = recommend.items.first;
  stdout.writeln('== 测试房间 ${room.roomId} ==');
  var detail = await site.getRoomDetail(roomId: room.roomId);
  stdout.writeln(
      '状态: ${detail.status} | 房间号: ${detail.roomId} | 主播: ${detail.userName}');
  if (!detail.status) {
    stdout.writeln('!! 接口显示未开播');
    exit(2);
  }
  var qualities = await site.getPlayQualites(detail: detail);
  stdout.writeln('清晰度数量: ${qualities.length}');
  for (var q in qualities) {
    var n = q.data is List ? (q.data as List).length : 0;
    stdout.writeln('  ${q.quality} (线路数=$n)');
  }
  if (qualities.isEmpty) {
    stdout.writeln('!! 无法获取清晰度');
    exit(3);
  }
  var play = await site.getPlayUrls(detail: detail, quality: qualities.first);
  stdout.writeln('播放地址数量: ${play.urls.length}');
  for (var u in play.urls) {
    stdout.writeln(
        'URL: ${u.substring(0, u.length > 100 ? 100 : u.length)}...');
    try {
      var client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      var req = await client.openUrl('GET', Uri.parse(u));
      req.headers.add('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
      var resp = await req.close();
      stdout.writeln('  -> HTTP ${resp.statusCode} ${resp.headers.contentType}');
      var total = 0;
      await for (var chunk in resp) {
        total += chunk.length;
        if (total > 200000) break;
      }
      stdout.writeln('  -> 收到 $total 字节数据 ${total > 0 ? "(流可用)" : "(空流!)"}');
      client.close();
    } catch (e) {
      stdout.writeln('  -> 请求失败: $e');
    }
  }
  exit(0);
}
