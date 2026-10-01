// Brauzerning haqiqiy to'liq ekran rejimi (F11 kabi). Web bo'lmagan platformalarda
// hech narsa qilmaydi — ilova ichidagi to'liq ekran baribir ishlaydi.
export 'fullscreen_stub.dart' if (dart.library.js_interop) 'fullscreen_web.dart';
