#import "GCDWebUploader.h"

#warning need fix GCDWebServer GCDWebUploader instantiation method
#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/me.ray.webserver.bundle"

static void * observer = NULL;
static GCDWebUploader* webUploader = NULL;

static void UIApplicationDidFinishLaunchingNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  	webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    NSLog(@"WebServer: GCDWebUploader has been created: %@", webUploader);
}

static void UIApplicationDidBecomeActiveNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [webUploader start];
  	NSLog(@"WebServer: Visit (webUploader=%@) %@ in your web browser", webUploader, webUploader.serverURL);
}

static void UIApplicationWillResignActiveNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
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


