#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
t=out/test/macho/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -shared -xc -
void foo() {}
EOF

clang --ld-path=./ld64 -shared -o $t/libfoo.dylib $t/a.o

cat <<EOF | $CC -o $t/b.o -c -xc -
void bar() {}
EOF

clang -shared -o $t/libbar.dylib $t/b.o -L$t -Wl,-reexport-lfoo

objdump --macho --dylibs-used $t/libbar.dylib | grep -q 'libfoo.*reexport'

echo OK