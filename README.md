# MacPorts gcc10-bootstrap branch

This branch is based on gcc 10.3.0 and contians additional patches which I've
used for MacPorts's [gcc10-bootstrap](https://ports.macports.org/port/gcc10-bootstrap/) port.

Summary:
- Iains' gcc-10-branches:
  - https://github.com/iains/gcc-10-branch/commit/be9bc6a38c7af727ed7fbd6b231b2c6162c48b8b
  - https://github.com/iains/gcc-10-branch/commit/d68cef7330b8ec3cc2917fa20e8090fc56a39bd5
  - https://github.com/iains/gcc-10-branch/commit/88d872abe4f9022e38ef34a63184a51f93748f8e
- macOS 12 compatibility:
  - https://github.com/gcc-mirror/gcc/commit/11b967577483e51f97d540e9c2c9d1ea76da8122
  - force to use C++11 on macOS 11+ for https://trac.macports.org/ticket/64316
    see: `Force to use C++11 on macOS 11+`
  - compatibility issue introduced by https://github.com/iains/gcc-10-branch/commit/94f22ab8452d32232727d9bc4694a89e682e4039
    see: `Darwin: Allow to using rpaths after darwin20`
  - compatibility issue introduced by https://github.com/iains/gcc-10-branch/commit/be9bc6a38c7af727ed7fbd6b231b2c6162c48b8b
    see: `Darwin, libgcc: include support macOS 12+`
- PPC compatibility:
  - https://github.com/gcc-mirror/gcc/commit/4c3792d448964f7bd99e7eac2c29c9eb7c2bfb84
- i686 / Darwin compatibility:
  - https://github.com/gcc-mirror/gcc/commit/54258e22b0846aaa6bd3265f592feb161eecda75
  - https://github.com/gcc-mirror/gcc/commit/fb32372651882adee2d41052f1e59012e8bb32a7
  - https://github.com/gcc-mirror/gcc/commit/b240450b630da511fadda98bba4862033ff56950
