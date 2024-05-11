import 'package:flutter/material.dart';
import 'package:jvn_info_get/utils/control.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    String importFilePath = "";
    String datePublicStartY = "";
    String datePublicStartM = "";
    double score = 0;
    String exportFilePath = "";

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("入力元"),
            TextField(
              onChanged: (value) => importFilePath = value,
            ),
            const SizedBox(height: 30),
            const Text("発見日開始年"),
            TextField(
              onChanged: (value) => datePublicStartY = value,
            ),
            const SizedBox(height: 30),
            const Text("発見日開始月"),
            TextField(
              onChanged: (value) => datePublicStartM = value,
            ),
            const SizedBox(height: 30),
            const Text("評価値"),
            TextField(
              onChanged: (value) => score = double.parse(value),
            ),
            const SizedBox(height: 30),
            const Text("出力先"),
            TextField(
              onChanged: (value) => exportFilePath = value,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => importFilePath == "" ||
                        exportFilePath == "" ||
                        datePublicStartY == "" ||
                        datePublicStartM == "" ||
                        score == 0
                    ? print(
                        'importFilePath:$importFilePath exportFilePath:$exportFilePath datePublicStartY:$datePublicStartY datePublicStartM:$datePublicStartM score:$score')
                    : Control().exec(
                        importFilePath: importFilePath,
                        exportFilePath: exportFilePath,
                        datePublicStartY: datePublicStartY,
                        datePublicStartM: datePublicStartM,
                        score: score,
                      ),
                child: const Text("実行"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
