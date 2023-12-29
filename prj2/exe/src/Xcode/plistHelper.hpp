#if defined(DEBUG)
#define PRODUCT_NAME StepMania-debug
#elif defined(MINSIZEREL)
#define PRODUCT_NAME StepMania-min-size
#elif defined(RELWITHDEBINFO)
#define PRODUCT_NAME StepMania-release-symbols
#else
#define PRODUCT_NAME StepMania
#endif

