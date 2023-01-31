#include "lib1/hdr.h"

#include <iostream>

namespace lib1 {

void f() {
	std::cout << "lib1::" << static_cast<const char*>(__FUNCTION__) << '\n';
}

} // namespace lib1

