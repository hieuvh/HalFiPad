#import "TweakCommon.h"
#define keyy(key) CFEqual(string, CFSTR(key))
#include <sys/sysctl.h>

NSInteger bottomInset;
NSInteger KeyboardHeight = 46, KeyboardBound = -18;

//Keyboard options
BOOL isHigherKeyboard, isDarkKeyboard, isNonLatinKeyboard;

//Camera Options
BOOL isCameraBottomSet, isCameraUI11, isCameraZoomFlip11;

BOOL isPIP;

// Edge Inset / fix top for iOS 14
%hook UIWindow
-(UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets orig = %orig;
    if (enabled) {
        if (@available(iOS 14.0, *)) {
            CGFloat const screenHeight = UIScreen.mainScreen.bounds.size.height;
            if (screenHeight >= 568 && screenHeight <= 736) {
                orig.top = 20;
            }
        }
        orig.bottom = bottomInset;
    }
    return orig;
}
%end

%group FixInstagram
%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
	if (strcmp(name, "hw.machine") == 0) {
        int ret = %orig;
        if (oldp) {
            const char *mechine1 = "iPhone12,1";
            strcpy((char *)oldp, mechine1);
        }
        return ret;
    } else {
        return %orig;
    }
}
%end

// Fix Twitter
%group FixTwitter
%hook TFNNavigationBarOverlayView
- (void)setFrame:(CGRect)frame {
    if (statusBarMode == 3) {
        %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + 6));
    } else {
        %orig;
    }
}
%end
%end

// Fix for Tiktok, ViettelPay, Instagram, Twitter
%group FixStatusBarInApp
%hook UIStatusBarManager
-(double)statusBarHeight {
    return 20;
}
%end
%end

// Fix Youtube
%group FixYouTube
%hook UIStatusBarManager
-(BOOL)isStatusBarHidden {
    return YES;
}
%end

%hook YTSearchView
- (void)setFrame:(CGRect)frame {
    if (statusBarMode == 3)
        %orig(CGRectSetY(frame, 40));
    else
        %orig(CGRectSetY(frame, 20));
}
%end

%hook YTWrapperView
- (void)setFrame:(CGRect)frame {
    if (statusBarMode == 3)
        %orig(CGRectSetY(frame, frame.origin.y + 10));
    else
        %orig;
}
%end
%end

// Dark Keyboard
%group DarkKeyBoard
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)arg1 {
        %orig(NO);
}
%end
%end

// Default Keyboard
%group DefaultKeyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(long long)arg1 inputMode:(id)arg2 {
    UIEdgeInsets const orig = %orig;
    if(!isNonLatinKeyboard) return UIEdgeInsetsMake(orig.top, 0, 0, 0);
    return UIEdgeInsetsMake(orig.top, orig.left, 0, orig.right);
}
%end
%end

// Higher Keyboard X
%group HigherKeyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(long long)arg1 inputMode:(id)arg2 {
	UIEdgeInsets const orig = %orig;
    if(!isNonLatinKeyboard) return UIEdgeInsetsMake(orig.top, 0, KeyboardHeight, 0);
    return UIEdgeInsetsMake(orig.top, orig.left, KeyboardHeight, orig.right);
}
%end

%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect const bounds = %orig;
    return CGRectSetY(bounds, KeyboardBound);
}
%end
%end

// Landscape Mode
%group iPadAppStyle
%hook UITraitCollection
+(id)traitCollectionWithHorizontalSizeClass:(long long)arg1 {
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        return %orig(2);
    return %orig;
}
%end
%end

// Picture in Picture
%group PictureInPicture
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef string) {
	if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
		return YES;
	return %orig;
}
%end

// Camera UI Set
%group CameraUISet
%hook CAMCaptureCapabilities
-(BOOL)isCTMSupported {
    return isCameraUI11;
}
%end

%hook CAMFlipButton
-(BOOL)_useCTMAppearance {
    return isCameraZoomFlip11;
}
%end

%hook CAMViewfinderViewController
-(BOOL)_shouldUseZoomControlInsteadOfSlider {
    return isCameraZoomFlip11;
}
%end
%end

// Camera Bottom Inset
%group CameraBottomSet
%hook CAMZoomControl
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - bottomInset));
}
%end

%hook CAMBottomBar
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - bottomInset));
}
%end
%end


static bool appID(NSString *keyString) {
    return [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:keyString];
}

// Tweak handle
static void updatePrefs() {
    @autoreleasepool {
        NSString *path = @"/User/Library/Preferences/com.hius.HalFiPadPrefs.plist";
        NSString *pathDefault = @"/Library/PreferenceBundles/HalFiPadPrefs.bundle/defaults.plist";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
        }
        NSDictionary const *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
        if (prefs) {
            enabled = boolValueForKey(@"Enabled", prefs);
            statusBarMode = intValueForKey(@"statusBarMode", prefs);
            screenMode = intValueForKey(@"screenMode", prefs);
            bottomInset = intValueForKey(@"bottomInset", prefs);
            KeyboardHeight = intValueForKey(@"bottomHeightKB", prefs);
            KeyboardBound = intValueForKey(@"boundKeyboard", prefs);
            isPIP = boolValueForKey(@"pictureInPicture", prefs);
            //Keyboard options:
            isHigherKeyboard = boolValueForKey(@"highKeyboard", prefs);
            isDarkKeyboard = boolValueForKey(@"darkKeyboard", prefs);
            isNonLatinKeyboard = boolValueForKey(@"nonLatinKeyboard", prefs);
            // More options:
            isCameraBottomSet = boolValueForKey(@"cameraBottomSet", prefs);
            isCameraUI11 = boolValueForKey(@"cameraUI11", prefs);
            isCameraZoomFlip11 = boolValueForKey(@"cameraZoomFlip11", prefs);
            //Per-App Customize
            NSString const *mainAppID = [NSBundle mainBundle].bundleIdentifier;
            NSDictionary const *appCustomize = [prefs objectForKey:mainAppID];
            if (appCustomize) {
                screenMode = (NSInteger)[[appCustomize objectForKey:@"screenMode"]?:((NSNumber *)[NSNumber numberWithBool:screenMode]) integerValue];
                bottomInset = (NSInteger)[[appCustomize objectForKey:@"bottomInset"]?:((NSNumber *)[NSNumber numberWithBool:bottomInset]) integerValue];
                isDarkKeyboard = (BOOL)[[appCustomize objectForKey:@"darkKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isDarkKeyboard]) boolValue];
                isHigherKeyboard = (BOOL)[[appCustomize objectForKey:@"highKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isHigherKeyboard]) boolValue];
                isNonLatinKeyboard = (BOOL)[[appCustomize objectForKey:@"nonLatinKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isNonLatinKeyboard]) boolValue];
            }
        }
    }
}

%ctor {
    @autoreleasepool {
        %init;
        updatePrefs();
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs,
            CFSTR("com.hius.HalFiPadPrefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce
        );

        if (enabled) {
            bool const isApp = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"];

            if (isApp) {
                if (statusBarMode == 3 || statusBarMode == 2) {
                    if (appID(@"com.ss.iphone.ugc.Ame") || appID(@"com.viettel.viettelpay") || appID(@"com.atebits.Tweetie2") || (statusBarMode == 2 && appID(@"com.burbn.instagram")))
                        %init(FixStatusBarInApp);
                    else if (appID(@"com.google.ios.youtube"))
                        %init(FixYouTube);
                    else if (appID(@"com.facebook.Facebook"))
                        bottomInset += 5;
                    else if (statusBarMode == 3 && appID(@"com.burbn.instagram"))
                        %init(FixInstagram);
                }

                if (appID(@"com.atebits.Tweetie2")) {
                    bottomInset += 2;
                    %init(FixTwitter);
                } else if (appID(@"com.apple.camera")) {
                    %init(CameraUISet);
                    if (isCameraBottomSet)
                        %init(CameraBottomSet);
                }

                if (screenMode == 0) {
                    if (appID(@"com.apple.weather")) return;
                    %init(iPadAppStyle);
                }
            }

            if (@available(iOS 14.0, *)) {
                isPIP = NO;
            } else {
                if (isPIP) %init(PictureInPicture);
            }

            // Keyboard Options
            if (isDarkKeyboard)
                %init(DarkKeyBoard);

            if (isHigherKeyboard)
                %init(HigherKeyboard);
            else
                %init(DefaultKeyboard);
        }
    }
}