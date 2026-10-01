// Jangni video faylga eksport qilish. Webda brauzerning WebCodecs kodlovchisi (VP9/VP8)
// ishlatiladi; boshqa platformalarda hozircha mavjud emas.
export 'video_export_stub.dart' if (dart.library.js_interop) 'video_export_web.dart';
