#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#error "!defined(LIB1_MACRO)"
#endif // !LIB1_MACRO

namespace lib2 {
void f();
} // namespace lib2

int main() {
	lib2::f();
	return 0;
}
