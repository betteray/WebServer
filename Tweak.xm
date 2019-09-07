#import <CydiaSubstrate2.h>
#import "GCDWebUploader.h"

// #import "GCDWebServer.h"
// #import "GCDWebServerDataResponse.h"

#warning need fix GCDWebServer GCDWebUploader instantiation method
#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/me.ray.webserver.bundle"

static NSString * const APP_DELEGATE_CLASS = @"MicroMessengerAppDelegate";

DefineHook(BOOL, application_didFinishLaunchingWithOptions_, id self, SEL _cmd, UIApplication * application, NSDictionary *launchOptions) {
    BOOL result = original_application_didFinishLaunchingWithOptions_(self, _cmd, application, launchOptions);
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  	GCDWebUploader* webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
  	[webUploader start];
  	NSLog(@"GCDWebUploader: Visit (webUploader=%@) %@ in your web browser", webUploader, webUploader.serverURL);

    return result;
}

%ctor {
    InstallObjCInstanceHook(NSClassFromString(APP_DELEGATE_CLASS), 
                            @selector(application:didFinishLaunchingWithOptions:), 
                            application_didFinishLaunchingWithOptions_);
}


