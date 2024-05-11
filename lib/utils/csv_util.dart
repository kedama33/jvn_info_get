import 'dart:convert';
import 'dart:io';

import 'package:jvn_info_get/models/vuln.dart';

class CSVUtil {
  static Future<List<String>> importCSV(
      {required String importFilePath}) async {
    File importFile = File(importFilePath);
    Stream fread = importFile.openRead();

    List<String> productNameList = [];
    await fread.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (String value) {
        productNameList.add(value);
      },
    ).asFuture();

    return productNameList;
  }

  static Future exportCSV({
    required String exportFilePath,
    required List<Vuln> dataList,
  }) async {
    File exportFile = File('$exportFilePath/result.csv');
    for (Vuln data in dataList) {
      await exportFile.writeAsString(
        '${data.productName}, ${data.url}\n',
        mode: FileMode.append,
      );
    }
  }
}
