import 'package:logger/web.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class MyJvnUtil {
  /// 該当する脆弱性対策情報を取得
  static Future<List<String>?> getVulnOverviewListInfoByProductId({
    required String productId,
    required String dateFirstPublishedStartY,
    required String dateFirstPublishedStartM,
    required String startItem,
  }) async {
    final logger = Logger();

    // 製品IDで検索
    String uri =
        "https://jvndb.jvn.jp/myjvn?method=getVulnOverviewList&feed=hnd&rangeDatePublic=n&rangeDatePublished=n&rangeDateFirstPublished=n&productId=$productId&dateFirstPublishedStartY=$dateFirstPublishedStartY&dateFirstPublishedStartM=$dateFirstPublishedStartM&startItem=$startItem";
    try {
      // 規約に「長時間の収集であれば秒間あたり2, 3アクセスよりアクセス頻度ゆるめてね」って書いてあったので、1秒に1回取得するようにする
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http.get(Uri.parse(uri));
      String data = response.body;
      XmlDocument decodedData = XmlDocument.parse(data);

      // 最初と最後はヒットした脆弱性対策情報以外のデータなのでいらない
      List<String> temp = decodedData.toString().split("</channel>");
      List<String> dataList = temp[1].split("</item>");
      dataList.removeLast();

      return dataList;
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  /// ヒットした脆弱性対策情報のURLを取得
  static String getURL({required String data}) {
    int start = data.indexOf("<link>") + 6;
    int end = data.indexOf("</link>");
    String link = data.substring(start, end);
    return link;
  }

  /// ヒットした脆弱性対策情報の評価値が指定された値以上かどうかを判定
  static bool isScoreOver({required String data, required double score}) {
    int start = data.indexOf("score=") + 7;
    int end = data.indexOf(" severity=") - 1;

    // "score"の文字列が見つからなかったら該当する脆弱性対策情報がなかったということなので、falseを返す
    if (start == 6) {
      return false;
    }

    double targetScore = double.parse(data.substring(start, end));
    return score <= targetScore ? true : false;
  }
}
