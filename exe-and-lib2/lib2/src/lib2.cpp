#include "hdr.h"
// #include "lib1/hdr.h"

#include <iostream>

namespace lib1 {
void f();
}

namespace lib2 {
void f() {
	std::cout << "lib2::" << __FUNCTION__ << '\n';
	lib1::f();
}
} // namespace lib2

