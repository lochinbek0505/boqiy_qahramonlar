/// Butun ilova bo'ylab bitta xil ekran o'lchov chegaralari.
/// Oldin har bir sahifa o'zining 600/650/800/1000 kabi alohida
/// raqamlaridan foydalanardi — bu esa turli sahifalarda mobil/desktop
/// holatlari mos kelmasligiga (masalan, appbar hali desktop rejimida,
/// lekin grid allaqachon mobil rejimda) va shu bilan bog'liq
/// "RenderFlex overflow" xatolariga olib kelardi.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 650;
  static const double tablet = 1000;

  static bool isMobile(double width) => width < mobile;

  static bool isTablet(double width) => width >= mobile && width < tablet;

  static bool isDesktop(double width) => width >= tablet;
}
