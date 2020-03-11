#import "GCDWebUploader.h"

#warning need fix GCDWebServer GCDWebUploader instantiation method
#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/me.ray.webserver.bundle"

static void * observer = NULL;
static GCDWebUploader* webUploader = NULL;
static bool is_apple_app() {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *appBundle = [infoDictionary objectForKey:@"CFBundleIdentifier"];

	return [appBundle containsString:@"apple"];
}

static void UIApplicationDidFinishLaunchingNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	// NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString* homePath = NSHomeDirectory();
  	webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    NSLog(@"WebServer: GCDWebUploader has been created: %@", webUploader);
}

static void UIApplicationDidBecomeActiveNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (webUploader == nil) return;
    if (webUploader.running) return;

    NSError *error = nil;
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInteger:80] forKey:GCDWebServerOption_Port];
    [options setValue:@"" forKey:GCDWebServerOption_BonjourName];

    if(![webUploader startWithOptions:options error:&error]) {
        NSLog(@"WebServer: start error: %@", error);
    } else {
        NSLog(@"WebServer: Visit (webUploader=%@) %@ in your web browser", webUploader, webUploader.serverURL);
    }
}

static void UIApplicationWillResignActiveNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (webUploader == nil) return;
    if (!webUploader.running) return;

    [webUploader stop];
    NSLog(@"WebServer: GCDWebUploader has been stoped.");
}
 
%hook NSBundle

// don't need touch GCDWebUploader source file or the instantiation of GCDWebUploader will failed.
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext {
    if([name isEqualToString:@"GCDWebUploader"] && [ext isEqualToString:@"bundle"]) {
      return kBundlePath;
    }
    
    return %orig;
}

%end

%ctor {
	if (is_apple_app()) {
        NSLog(@"It is apple app, i do not need.");
        return; // don't hook springboard, or when respring will cause iusue.
    }
    

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		UIApplicationDidFinishLaunchingNotificationCallback,
		(CFStringRef)UIApplicationDidFinishLaunchingNotification,
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);

  CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		UIApplicationDidBecomeActiveNotificationCallback,
		(CFStringRef)UIApplicationDidBecomeActiveNotification,
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);

  CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		UIApplicationWillResignActiveNotificationCallback,
		(CFStringRef)UIApplicationWillResignActiveNotification,
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);
}

// Remove observer upon unloading the dylib
%dtor {
	if (is_apple_app()) {
        NSLog(@"It is apple app, i do not need.");
        return; // don't hook springboard, or when respring will cause iusue.
    }
    
	CFNotificationCenterRemoveObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		(CFStringRef)UIApplicationDidFinishLaunchingNotification,
		NULL
	);

  CFNotificationCenterRemoveObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		(CFStringRef)UIApplicationDidBecomeActiveNotification,
		NULL
	);

  CFNotificationCenterRemoveObserver(
		CFNotificationCenterGetLocalCenter(),
		&observer,
		(CFStringRef)UIApplicationWillResignActiveNotification,
		NULL
	);
}


