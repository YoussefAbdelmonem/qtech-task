import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/loger.dart';

class AppBlocObserver extends BlocObserver {
  final LoggerDebug log =
      LoggerDebug(headColor: LogColors.white, constTitle: 'App Bloc Observer');

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log.blue('${bloc.runtimeType} ( onCreate )');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    final current = _extractEnum(change.currentState);
    final next = _extractEnum(change.nextState);

    if (next.toString().contains("failed") ||
        next.toString().contains("error")) {
      log.red('${bloc.runtimeType} ( onChange ), $current ==> $next');
    } else {
      log.green('${bloc.runtimeType} ( onChange ), $current ==> $next');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.red('${bloc.runtimeType} ( onError ), $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log.red('${bloc.runtimeType} ( onClose )');
  }

  String _extractEnum(Object state) {
    try {
      final fields = state.toString();
      final match = RegExp(r'([A-Za-z]+State\.[a-zA-Z0-9_]+)')
          .firstMatch(fields)
          ?.group(0);
      return match ?? state.runtimeType.toString();
    } catch (_) {
      return state.runtimeType.toString();
    }
  }
}
