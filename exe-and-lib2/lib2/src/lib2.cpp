#include "lib2/hdr.h"
#include "lib1/hdr.h"

#include <iostream>

#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#error "!defined(LIB1_MACRO)"
#endif // !LIB1_MACRO

namespace lib2 {
void f() {
	std::cout << "lib2::" << __FUNCTION__ << '\n';
	lib1::f();
}
} // namespace lib2

