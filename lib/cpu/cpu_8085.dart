class CPU8085 {
  int a = 0, b = 0, c = 0, d = 0, e = 0, h = 0, l = 0, sp = 0xFF00, pc = 0x0000;
  bool fS = false,
      fZ = false,
      fAC = false,
      fP = false,
      fC = false,
      inte = false,
      halted = false;
  List<int> mem = List.filled(0x10000, 0);
  int lastRunSteps = 0; // tracks steps from last run()

  void reset() {
    a = b = c = d = e = h = l = 0;
    sp = 0xFF00;
    pc = 0;
    fS = fZ = fAC = fP = fC = inte = halted = false;
    lastRunSteps = 0;
  }

  int get hl => (h << 8) | l;
  int get bc => (b << 8) | c;
  int get de => (d << 8) | e;
  void setHL(int v) {
    h = (v >> 8) & 0xFF;
    l = v & 0xFF;
  }

  void setBC(int v) {
    b = (v >> 8) & 0xFF;
    c = v & 0xFF;
  }

  void setDE(int v) {
    d = (v >> 8) & 0xFF;
    e = v & 0xFF;
  }

  bool _par(int v) {
    int n = 0;
    for (int i = 0; i < 8; i++) {
      if ((v >> i) & 1 == 1) n++;
    }
    return n % 2 == 0;
  }

  int _fl() {
    int f = 0x02;
    if (fS) f |= 0x80;
    if (fZ) f |= 0x40;
    if (fAC) f |= 0x10;
    if (fP) f |= 0x04;
    if (fC) f |= 0x01;
    return f;
  }

  void _sf(int f) {
    fS = (f & 0x80) != 0;
    fZ = (f & 0x40) != 0;
    fAC = (f & 0x10) != 0;
    fP = (f & 0x04) != 0;
    fC = (f & 0x01) != 0;
  }

  int _r(int a) => mem[a & 0xFFFF];
  void _w(int a, int v) => mem[a & 0xFFFF] = v & 0xFF;
  int _f() {
    final v = _r(pc);
    pc = (pc + 1) & 0xFFFF;
    return v;
  }

  int _f16() {
    final lo = _f(), hi = _f();
    return (hi << 8) | lo;
  }

  void _push(int v) {
    sp = (sp - 1) & 0xFFFF;
    _w(sp, (v >> 8) & 0xFF);
    sp = (sp - 1) & 0xFFFF;
    _w(sp, v & 0xFF);
  }

  int _pop() {
    final lo = _r(sp);
    sp = (sp + 1) & 0xFFFF;
    final hi = _r(sp);
    sp = (sp + 1) & 0xFFFF;
    return (hi << 8) | lo;
  }

  void _uf(int r) {
    final x = r & 0xFF;
    fZ = x == 0;
    fS = (x & 0x80) != 0;
    fP = _par(x);
    fC = r > 0xFF || r < 0;
  }

  void _add(int v, {bool cy = false}) {
    final c = cy && fC ? 1 : 0;
    final r = a + v + c;
    fAC = ((a & 0xF) + (v & 0xF) + c) > 0xF;
    _uf(r);
    a = r & 0xFF;
  }

  void _sub(int v, {bool bw = false}) {
    final bor = bw && fC ? 1 : 0;
    final r = a - v - bor;
    fAC = ((a & 0xF) - (v & 0xF) - bor) < 0;
    fC = r < 0;
    fZ = (r & 0xFF) == 0;
    fS = (r & 0x80) != 0;
    fP = _par(r & 0xFF);
    a = r & 0xFF;
  }

  void _ana(int v) {
    a &= v;
    fC = false;
    fAC = (a & 0x8) != 0;
    _uf(a);
    a &= 0xFF;
  }

  void _ora(int v) {
    a |= v;
    fC = fAC = false;
    _uf(a);
    a &= 0xFF;
  }

  void _xra(int v) {
    a ^= v;
    fC = fAC = false;
    _uf(a);
    a &= 0xFF;
  }

  void _cmp(int v) {
    final t = a;
    _sub(v);
    a = t;
  }

  int _gr(int c) {
    switch (c) {
      case 0:
        return b;
      case 1:
        return this.c;
      case 2:
        return d;
      case 3:
        return e;
      case 4:
        return h;
      case 5:
        return l;
      case 6:
        return _r(hl);
      case 7:
        return a;
    }
    return 0;
  }

  void _sr(int c, int v) {
    v &= 0xFF;
    switch (c) {
      case 0:
        b = v;
        break;
      case 1:
        this.c = v;
        break;
      case 2:
        d = v;
        break;
      case 3:
        e = v;
        break;
      case 4:
        h = v;
        break;
      case 5:
        l = v;
        break;
      case 6:
        _w(hl, v);
        break;
      case 7:
        a = v;
        break;
    }
  }

  bool step() {
    if (halted) return false;
    final op = _f();
    if (op >= 0x40 && op <= 0x7F) {
      if (op == 0x76) {
        halted = true;
        return false;
      }
      _sr((op >> 3) & 7, _gr(op & 7));
      return true;
    }
    if (op >= 0x80 && op <= 0xBF) {
      final s = _gr(op & 7);
      switch ((op >> 3) & 7) {
        case 0:
          _add(s);
          break;
        case 1:
          _add(s, cy: true);
          break;
        case 2:
          _sub(s);
          break;
        case 3:
          _sub(s, bw: true);
          break;
        case 4:
          _ana(s);
          break;
        case 5:
          _xra(s);
          break;
        case 6:
          _ora(s);
          break;
        case 7:
          _cmp(s);
          break;
      }
      return true;
    }
    switch (op) {
      case 0x00:
        break;
      case 0x06:
        b = _f();
        break;
      case 0x0E:
        c = _f();
        break;
      case 0x16:
        d = _f();
        break;
      case 0x1E:
        e = _f();
        break;
      case 0x26:
        h = _f();
        break;
      case 0x2E:
        l = _f();
        break;
      case 0x36:
        _w(hl, _f());
        break;
      case 0x3E:
        a = _f();
        break;
      case 0x01:
        setBC(_f16());
        break;
      case 0x11:
        setDE(_f16());
        break;
      case 0x21:
        setHL(_f16());
        break;
      case 0x31:
        sp = _f16();
        break;
      case 0x3A:
        a = _r(_f16());
        break;
      case 0x32:
        _w(_f16(), a);
        break;
      case 0x2A:
        {
          final addr = _f16();
          l = _r(addr);
          h = _r(addr + 1);
        }
        break;
      case 0x22:
        {
          final addr = _f16();
          _w(addr, l);
          _w(addr + 1, h);
        }
        break;
      case 0x0A:
        a = _r(bc);
        break;
      case 0x1A:
        a = _r(de);
        break;
      case 0x02:
        _w(bc, a);
        break;
      case 0x12:
        _w(de, a);
        break;
      case 0x04:
        {
          final r = (b + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (b & 0xF) == 0xF;
          b = r;
        }
        break;
      case 0x0C:
        {
          final r = (c + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (c & 0xF) == 0xF;
          c = r;
        }
        break;
      case 0x14:
        {
          final r = (d + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (d & 0xF) == 0xF;
          d = r;
        }
        break;
      case 0x1C:
        {
          final r = (e + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (e & 0xF) == 0xF;
          e = r;
        }
        break;
      case 0x24:
        {
          final r = (h + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (h & 0xF) == 0xF;
          h = r;
        }
        break;
      case 0x2C:
        {
          final r = (l + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (l & 0xF) == 0xF;
          l = r;
        }
        break;
      case 0x34:
        {
          final v = _r(hl);
          final r = (v + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (v & 0xF) == 0xF;
          _w(hl, r);
        }
        break;
      case 0x3C:
        {
          final r = (a + 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (a & 0xF) == 0xF;
          a = r;
        }
        break;
      case 0x05:
        {
          final r = (b - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (b & 0xF) == 0;
          b = r;
        }
        break;
      case 0x0D:
        {
          final r = (c - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (c & 0xF) == 0;
          c = r;
        }
        break;
      case 0x15:
        {
          final r = (d - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (d & 0xF) == 0;
          d = r;
        }
        break;
      case 0x1D:
        {
          final r = (e - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (e & 0xF) == 0;
          e = r;
        }
        break;
      case 0x25:
        {
          final r = (h - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (h & 0xF) == 0;
          h = r;
        }
        break;
      case 0x2D:
        {
          final r = (l - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (l & 0xF) == 0;
          l = r;
        }
        break;
      case 0x35:
        {
          final v = _r(hl);
          final r = (v - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (v & 0xF) == 0;
          _w(hl, r);
        }
        break;
      case 0x3D:
        {
          final r = (a - 1) & 0xFF;
          fZ = r == 0;
          fS = (r & 0x80) != 0;
          fP = _par(r);
          fAC = (a & 0xF) == 0;
          a = r;
        }
        break;
      case 0x03:
        setBC((bc + 1) & 0xFFFF);
        break;
      case 0x13:
        setDE((de + 1) & 0xFFFF);
        break;
      case 0x23:
        setHL((hl + 1) & 0xFFFF);
        break;
      case 0x33:
        sp = (sp + 1) & 0xFFFF;
        break;
      case 0x0B:
        setBC((bc - 1) & 0xFFFF);
        break;
      case 0x1B:
        setDE((de - 1) & 0xFFFF);
        break;
      case 0x2B:
        setHL((hl - 1) & 0xFFFF);
        break;
      case 0x3B:
        sp = (sp - 1) & 0xFFFF;
        break;
      case 0x09:
        {
          final r = hl + bc;
          fC = r > 0xFFFF;
          setHL(r & 0xFFFF);
        }
        break;
      case 0x19:
        {
          final r = hl + de;
          fC = r > 0xFFFF;
          setHL(r & 0xFFFF);
        }
        break;
      case 0x29:
        {
          final r = hl + hl;
          fC = r > 0xFFFF;
          setHL(r & 0xFFFF);
        }
        break;
      case 0x39:
        {
          final r = hl + sp;
          fC = r > 0xFFFF;
          setHL(r & 0xFFFF);
        }
        break;
      case 0xC6:
        _add(_f());
        break;
      case 0xCE:
        _add(_f(), cy: true);
        break;
      case 0xD6:
        _sub(_f());
        break;
      case 0xDE:
        _sub(_f(), bw: true);
        break;
      case 0xE6:
        _ana(_f());
        break;
      case 0xEE:
        _xra(_f());
        break;
      case 0xF6:
        _ora(_f());
        break;
      case 0xFE:
        _cmp(_f());
        break;
      case 0x07:
        {
          fC = (a & 0x80) != 0;
          a = ((a << 1) | (fC ? 1 : 0)) & 0xFF;
        }
        break;
      case 0x0F:
        {
          fC = (a & 0x01) != 0;
          a = ((a >> 1) | (fC ? 0x80 : 0)) & 0xFF;
        }
        break;
      case 0x17:
        {
          final cy = fC ? 1 : 0;
          fC = (a & 0x80) != 0;
          a = ((a << 1) | cy) & 0xFF;
        }
        break;
      case 0x1F:
        {
          final cy = fC ? 0x80 : 0;
          fC = (a & 0x01) != 0;
          a = ((a >> 1) | cy) & 0xFF;
        }
        break;
      case 0x2F:
        a = (~a) & 0xFF;
        break;
      case 0x3F:
        fC = !fC;
        break;
      case 0x37:
        fC = true;
        break;
      case 0x27:
        {
          int cor = 0;
          if (fAC || (a & 0xF) > 9) cor |= 0x06;
          if (fC || a > 0x99) {
            cor |= 0x60;
            fC = true;
          }
          a = (a + cor) & 0xFF;
          fZ = a == 0;
          fS = (a & 0x80) != 0;
          fP = _par(a);
        }
        break;
      case 0xEB:
        {
          final t = hl;
          setHL(de);
          setDE(t);
        }
        break;
      case 0xE3:
        {
          final lo = _r(sp), hi = _r(sp + 1);
          _w(sp, l);
          _w(sp + 1, h);
          l = lo;
          h = hi;
        }
        break;
      case 0xF9:
        sp = hl;
        break;
      case 0xE9:
        pc = hl;
        break;
      case 0xC5:
        _push(bc);
        break;
      case 0xD5:
        _push(de);
        break;
      case 0xE5:
        _push(hl);
        break;
      case 0xF5:
        _push((a << 8) | _fl());
        break;
      case 0xC1:
        setBC(_pop());
        break;
      case 0xD1:
        setDE(_pop());
        break;
      case 0xE1:
        setHL(_pop());
        break;
      case 0xF1:
        {
          final v = _pop();
          a = (v >> 8) & 0xFF;
          _sf(v & 0xFF);
        }
        break;
      case 0xC3:
        pc = _f16();
        break;
      case 0xC2:
        {
          final ad = _f16();
          if (!fZ) pc = ad;
        }
        break;
      case 0xCA:
        {
          final ad = _f16();
          if (fZ) pc = ad;
        }
        break;
      case 0xD2:
        {
          final ad = _f16();
          if (!fC) pc = ad;
        }
        break;
      case 0xDA:
        {
          final ad = _f16();
          if (fC) pc = ad;
        }
        break;
      case 0xE2:
        {
          final ad = _f16();
          if (!fP) pc = ad;
        }
        break;
      case 0xEA:
        {
          final ad = _f16();
          if (fP) pc = ad;
        }
        break;
      case 0xF2:
        {
          final ad = _f16();
          if (!fS) pc = ad;
        }
        break;
      case 0xFA:
        {
          final ad = _f16();
          if (fS) pc = ad;
        }
        break;
      case 0xCD:
        {
          final ad = _f16();
          _push(pc);
          pc = ad;
        }
        break;
      case 0xC4:
        {
          final ad = _f16();
          if (!fZ) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xCC:
        {
          final ad = _f16();
          if (fZ) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xD4:
        {
          final ad = _f16();
          if (!fC) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xDC:
        {
          final ad = _f16();
          if (fC) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xF4:
        {
          final ad = _f16();
          if (!fS) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xFC:
        {
          final ad = _f16();
          if (fS) {
            _push(pc);
            pc = ad;
          }
        }
        break;
      case 0xC9:
        pc = _pop();
        break;
      case 0xC0:
        if (!fZ) pc = _pop();
        break;
      case 0xC8:
        if (fZ) pc = _pop();
        break;
      case 0xD0:
        if (!fC) pc = _pop();
        break;
      case 0xD8:
        if (fC) pc = _pop();
        break;
      case 0xF0:
        if (!fS) pc = _pop();
        break;
      case 0xF8:
        if (fS) pc = _pop();
        break;
      case 0xC7:
        _push(pc);
        pc = 0x00;
        break;
      case 0xCF:
        _push(pc);
        pc = 0x08;
        break;
      case 0xD7:
        _push(pc);
        pc = 0x10;
        break;
      case 0xDF:
        _push(pc);
        pc = 0x18;
        break;
      case 0xE7:
        _push(pc);
        pc = 0x20;
        break;
      case 0xEF:
        _push(pc);
        pc = 0x28;
        break;
      case 0xF7:
        _push(pc);
        pc = 0x30;
        break;
      case 0xFF:
        _push(pc);
        pc = 0x38;
        break;
      case 0xFB:
        inte = true;
        break;
      case 0xF3:
        inte = false;
        break;
      case 0x20:
        a = 0x00;
        break;
      case 0x30:
        break;
      case 0x76:
        halted = true;
        return false;
      default:
        break;
    }
    return true;
  }

  void run({int max = 100000}) {
    lastRunSteps = 0;
    while (!halted && lastRunSteps < max) {
      step();
      lastRunSteps++;
    }
  }

  int fl() => _fl();
  void sf(int f) => _sf(f);
}
