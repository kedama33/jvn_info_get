import 'package:flutter/material.dart';
import 'package:jvn_info_get/utils/control.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String importFilePath = "";
    String dateFirstPublishedStartY = DateTime.now().year.toString();
    String dateFirstPublishedStartM = (DateTime.now().month - 1).toString();
    double? score = 7.0;
    String exportFilePath = "";

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("入力元"),
                TextFormField(
                  onChanged: (value) => importFilePath = value,
                  validator: (value) => inputCheck(value: value),
                ),
                const SizedBox(height: 30),
                const Text("発行日開始年"),
                TextFormField(
                  initialValue: dateFirstPublishedStartY,
                  onChanged: (value) => dateFirstPublishedStartY = value,
                  validator: (value) => inputCheck(value: value),
                ),
                const SizedBox(height: 30),
                const Text("発行日開始月"),
                TextFormField(
                  initialValue: dateFirstPublishedStartM,
                  onChanged: (value) => dateFirstPublishedStartM = value,
                  validator: (value) => inputCheck(value: value),
                ),
                const SizedBox(height: 30),
                const Text("評価値"),
                TextFormField(
                  initialValue: score.toString(),
                  onChanged: (value) => score = double.parse(value),
                  validator: (value) => inputCheck(value: value),
                ),
                const SizedBox(height: 30),
                const Text("出力先"),
                TextFormField(
                  onChanged: (value) => exportFilePath = value,
                  validator: (value) => inputCheck(value: value),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 未入力の欄があったら処理を行わない
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        // 処理の実行中は「検索中」を表示する
                        await showExecutingDialog(
                          context: context,
                          completed: false,
                        );

                        // 検索処理を実行
                        await Control().exec(
                          importFilePath: importFilePath,
                          exportFilePath: exportFilePath,
                          dateFirstPublishedStartY: dateFirstPublishedStartY,
                          dateFirstPublishedStartM: dateFirstPublishedStartM,
                          score: score!,
                        );

                        // 処理が終了したら、「完了」を表示する
                        if (!context.mounted) return;
                        await showExecutingDialog(
                          context: context,
                          completed: true,
                        );
                      }
                    },
                    child: const Text("実行"),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  String? inputCheck({required String? value}) {
    return value == null || value.isEmpty ? "必須入力です" : null;
  }

  Future showExecutingDialog({
    required BuildContext context,
    required bool completed,
  }) async {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(completed ? '完了' : '検索中..'),
                    const SizedBox(height: 30),
                    completed
                        ? Column(
                            children: [
                              const Icon(Icons.check),
                              const SizedBox(height: 50),
                              ElevatedButton(
                                onPressed: () {
                                  int count = 0;
                                  Navigator.popUntil(
                                      context, (_) => count++ >= 2);
                                },
                                child: const Text("検索画面に戻る"),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
        });
  }
}
