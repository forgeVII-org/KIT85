enum KitState { idle, exmem, go, exreg }

enum RegView { a, b, c, d, e, h, l, sp, pc, flags }

extension RegViewExt on RegView {
  String get label {
    switch (this) {
      case RegView.a:
        return 'A';
      case RegView.b:
        return 'B';
      case RegView.c:
        return 'C';
      case RegView.d:
        return 'D';
      case RegView.e:
        return 'E';
      case RegView.h:
        return 'H';
      case RegView.l:
        return 'L';
      case RegView.sp:
        return 'SP';
      case RegView.pc:
        return 'PC';
      case RegView.flags:
        return 'F';
    }
  }

  bool get is16 => this == RegView.sp || this == RegView.pc;
}
