import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> enterBrowserFullscreen() async {
  try {
    await web.document.documentElement?.requestFullscreen().toDart;
  } catch (_) {
    // Brauzer ruxsat bermasa (masalan, iframe ichida) — ilova ichidagi rejim yetarli.
  }
}

Future<void> exitBrowserFullscreen() async {
  if (web.document.fullscreenElement == null) return;
  try {
    await web.document.exitFullscreen().toDart;
  } catch (_) {}
}

bool get isBrowserFullscreen => web.document.fullscreenElement != null;

void Function() onBrowserFullscreenChange(void Function(bool fullscreen) callback) {
  final listener = ((web.Event _) => callback(isBrowserFullscreen)).toJS;
  web.document.addEventListener('fullscreenchange', listener);
  return () => web.document.removeEventListener('fullscreenchange', listener);
}
