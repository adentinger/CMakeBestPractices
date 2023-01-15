#include "hdr.h"

#include <iostream>

namespace lib1 {

void f() {
	std::cout << __FUNCTION__ << '\n';
}

} // namespace lib1

