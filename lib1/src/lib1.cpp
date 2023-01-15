#include "hdr.h"

#include <iostream>

namespace lib1 {

void f() {
	std::cout << "lib1::" << __FUNCTION__ << '\n';
}

} // namespace lib1

