import 'package:flutter/material.dart';
import 'package:hetu_script/hetu/hetu.dart';
import 'package:hetu_script_flutter/hetu_script_flutter.dart';

class ScriptRunner extends StatefulWidget {
  const ScriptRunner({super.key});

  @override
  State<ScriptRunner> createState() => _ScriptRunnerState();
}

class _ScriptRunnerState extends State<ScriptRunner> {
  _ScriptState state = _ScriptIsLoading();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final sourceContext = HTAssetResourceContext(root: 'assets/scripts');
    final hetu = Hetu(sourceContext: sourceContext);
    await hetu.initFlutter();
    setState(() {
      try {
        state = _ScriptIsRunning(
            value: hetu.evalFile('assets/scripts/main.ht', invokeFunc: 'main'));
      } catch (e, stacktrace) {
        state = _ScriptHasFailed(error: e, stackTrace: stacktrace);
      }
      debugPrint(state.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _ScriptIsLoading() => const CircularProgressIndicator(),
      _ScriptHasFailed() => Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(3 * 8.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      state.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      _ => const Placeholder(),
    };
  }
}

sealed class _ScriptState {}

class _ScriptIsLoading extends _ScriptState {}

class _ScriptIsRunning extends _ScriptState {
  final Object value;
  _ScriptIsRunning({required this.value});

  @override
  String toString() {
    return '_ScriptIsRunning{value: $value}';
  }
}

class _ScriptHasFailed extends _ScriptState {
  final Object error;
  final StackTrace? stackTrace;
  _ScriptHasFailed({required this.error, this.stackTrace});

  @override
  String toString() {
    return '_ScriptHasFailed{error: $error, stackTrace:$stackTrace}';
  }
}
