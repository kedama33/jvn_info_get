import 'package:jvn_info_get/utils/csv_util.dart';
import 'package:jvn_info_get/utils/my_jvn_util.dart';
import 'package:jvn_info_get/models/vuln.dart';
import 'package:logger/web.dart';

class Control {
  final logger = Logger();

  Future exec({
    required String importFilePath,
    required String exportFilePath,
    required String dateFirstPublishedStartY,
    required String dateFirstPublishedStartM,
    required double score,
  }) async {
    // 検索する製品IDをcsvファイルから取得
    logger.t('csvファイル読み込み開始');
    List<String> productIdList =
        await CSVUtil.importCSV(importFilePath: importFilePath);
    logger.t('csvファイル読み込み完了');

    // 出力するデータのリスト
    List<Vuln> resultList = [];

    for (String productId in productIdList) {
      // 対象の製品IDをJVNで検索し、該当する脆弱性対策情報を取得
      logger.t('JVN検索開始 : $productId');
      List<String> dataList = [];
      int startItem = 1;
      do {
        List<String>? tempList =
            await MyJvnUtil.getVulnOverviewListInfoByProductId(
          productId: productId,
          dateFirstPublishedStartY: dateFirstPublishedStartY,
          dateFirstPublishedStartM: dateFirstPublishedStartM,
          startItem: startItem.toString(),
        );
        if (tempList == null) {
          logger.e("脆弱性対策情報が取得できませんでした");
          return;
        }
        for (String temp in tempList) {
          dataList.add(temp);
        }

        // 無限ループ対策
        if (dataList.length >= 1000) {
          logger.e('無限ループの可能性があります');
          return;
        }
        startItem = dataList.length + 1;

        // 最大50件までしか取得できないので、51件目以降がある場合は51件目から再度取得
      } while (dataList.length % 50 == 0);
      logger.t('JVN検索完了 : $productId');

      for (String data in dataList) {
        // ヒットした脆弱性対策情報が指定された評価値より高い場合
        if (MyJvnUtil.isScoreOver(data: data, score: score)) {
          // 取得した脆弱性対策情報からヒットしたURLを取得
          logger.t('JVNヒットURL検索開始 : $productId');
          String url = MyJvnUtil.getURL(data: data);
          if (url != 'https://jvndb.jvn.jp/apis/myjvn') {
            resultList.add(Vuln(productId: productId, url: url));
          }
          logger.t('JVNヒットURL検索完了 : $productId');
        }
      }
    }

    // 結果リストをcsvに出力
    logger.t('csv出力開始');
    await CSVUtil.exportCSV(
      exportFilePath: exportFilePath,
      dataList: resultList,
    );
    logger.t('csv出力完了');
  }
}
