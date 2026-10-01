Future<void> enterBrowserFullscreen() async {}

Future<void> exitBrowserFullscreen() async {}

bool get isBrowserFullscreen => false;

/// Foydalanuvchi Esc bosib chiqqanini bilish uchun. Obunani bekor qiluvchi funksiyani qaytaradi.
void Function() onBrowserFullscreenChange(void Function(bool fullscreen) callback) => () {};
