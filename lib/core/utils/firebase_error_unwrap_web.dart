import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Object unwrapFirebaseError(Object error) {
  if (error.runtimeType.toString() != 'NativeError') return error;

  final boxedError = (error as JSObject)
      .getProperty<JSBoxedDartObject?>('error'.toJS);
  return boxedError?.toDart ?? error;
}
