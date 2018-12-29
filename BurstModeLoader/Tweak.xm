#import "../../PS.h"
#import <dlfcn.h>

%ctor {
    if (isiOS9Up)
        dlopen("/Library/Application Support/BurstMode/BurstModeiOS910.dylib", RTLD_LAZY);
    else if (isiOS8)
        dlopen("/Library/Application Support/BurstMode/BurstModeiOS8.dylib", RTLD_LAZY);
    else if (isiOS7)
        dlopen("/Library/Application Support/BurstMode/BurstModeiOS7.dylib", RTLD_LAZY);
#if !__LP64__
    else
        dlopen("/Library/Application Support/BurstMode/BurstModeiOS56.dylib", RTLD_LAZY);
#endif
}
