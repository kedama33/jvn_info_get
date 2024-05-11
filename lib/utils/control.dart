import 'package:jvn_info_get/utils/csv_util.dart';
import 'package:jvn_info_get/utils/my_jvn_util.dart';
import 'package:jvn_info_get/models/vuln.dart';

class Control {
  Future exec({
    required String importFilePath,
    required String exportFilePath,
    required String datePublicStartY,
    required String datePublicStartM,
    required double score,
  }) async {
    // 検索する製品名をcsvファイルから取得
    print('csvファイル読み込み開始');
    List<String> productNameList =
        await CSVUtil.importCSV(importFilePath: importFilePath);
    print('csvファイル読み込み完了');

    // 出力するデータのリスト
    List<Vuln> resultList = [];

    for (String productName in productNameList) {
      // 対象の製品名をJVNで検索し、該当する脆弱性対策情報を取得
      print('JVN検索開始 : $productName');
      List<String> dataList = [];
      int startItem = 1;
      do {
        List<String>? tempList = await MyJvnUtil.getVulnOverviewListInfo(
          keyword: productName,
          datePublicStartY: datePublicStartY,
          datePublicStartM: datePublicStartM,
          startItem: startItem.toString(),
        );
        if (tempList == null) {
          print("脆弱性対策情報が取得できませんした");
          return;
        }
        for (String temp in tempList) {
          dataList.add(temp);
        }

        // 無限ループ対策
        if (dataList.length >= 300) {
          print('無限ループの可能性があります');
          return;
        }
        startItem = dataList.length + 1;
        print(startItem);

        // 最大50件までしか取得できないので、51件目以降がある場合は51件目から再度取得
      } while (startItem != 1 && startItem % 50 == 1);
      print('JVN検索完了 : $productName');

      for (String data in dataList) {
        // ヒットした脆弱性対策情報が指定された評価値より高い場合
        if (MyJvnUtil.isScoreOver(data: data, score: score)) {
          // 取得した脆弱性対策情報からヒットしたURLを取得
          print('JVNヒットURL検索開始 : $productName');
          String url = MyJvnUtil.getURL(data: data);
          if (url != 'https://jvndb.jvn.jp/apis/myjvn') {
            resultList.add(Vuln(productName: productName, url: url));
          }
          print('JVNヒットURL検索完了 : $productName');
        }
      }
    }

    // 結果リストをcsvに出力
    print('csv出力開始');
    await CSVUtil.exportCSV(
      exportFilePath: exportFilePath,
      dataList: resultList,
    );
    print('csv出力完了');
  }
}
