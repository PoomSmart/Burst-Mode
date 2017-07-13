#import "../PS.h"
#import <dlfcn.h>

%ctor
{
	if (isiOS10Up)
		dlopen("/Library/Application Support/BurstMode/BurstModeiOS10.dylib", RTLD_LAZY);
	else if (isiOS9)
		dlopen("/Library/Application Support/BurstMode/BurstModeiOS9.dylib", RTLD_LAZY);
	else if (isiOS8)
		dlopen("/Library/Application Support/BurstMode/BurstModeiOS8.dylib", RTLD_LAZY);
	else if (isiOS7)
		dlopen("/Library/Application Support/BurstMode/BurstModeiOS7.dylib", RTLD_LAZY);
	else if (isiOS56)
		dlopen("/Library/Application Support/BurstMode/BurstModeiOS56.dylib", RTLD_LAZY);
}
