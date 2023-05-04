# gcc10-bootstrap branch

This branch is based on [gcc
10.4.0](https://github.com/gcc-mirror/gcc/releases/tag/releases%2Fgcc-10.4.0)
and contains additional patches I've used for MacPort's
[gcc10-bootstrap](https://ports.macports.org/port/gcc10-bootstrap/) port. The
goal is to make GCC 10 a universal compiler that can be used on any MacOS 10+ on
PPC, x86 or AMR64 platform as a universal bootstrap compiler.

Why is that? Because GCC 10 is the last compiler that can be bootstrapped from ISO C++98.

It contains:
- Iains' gcc-10-branches:
  - https://github.com/iains/gcc-10-branch/commit/be9bc6a38c7af727ed7fbd6b231b2c6162c48b8b
  - https://github.com/iains/gcc-10-branch/commit/d68cef7330b8ec3cc2917fa20e8090fc56a39bd5
  - https://github.com/iains/gcc-10-branch/commit/88d872abe4f9022e38ef34a63184a51f93748f8e
- macOS 12+ compatibility:
  - force to use C++11 on macOS 11+ for https://trac.macports.org/ticket/64316
    see: `Force to use C++11 on macOS 11+`
  - compatibility problem introduced by https://github.com/iains/gcc-10-branch/commit/94f22ab8452d32232727d9bc4694a89e682e4039
    see: `Darwin: Allow to using rpaths after darwin20`
  - compatibility problem introduced by  https://github.com/iains/gcc-10-branch/commit/be9bc6a38c7af727ed7fbd6b231b2c6162c48b8b
    see: `Darwin, libgcc: include support macOS 12+`
  - compatibility problem introduced by https://github.com/iains/gcc-10-branch/commit/94f22ab8452d32232727d9bc4694a89e682e4039
    see: `Darwin: Allow to using rpaths after darwin20`
  - https://github.com/gcc-mirror/gcc/commit/254e88b3d7e8abcc236be3451609834371cf4d5d
- PPC compatibility:
  - https://github.com/gcc-mirror/gcc/commit/4c3792d448964f7bd99e7eac2c29c9eb7c2bfb84

All branches below will be merged into one set of patches.

Thus, this branch will be force-pushed to the next release of GCC 10.
