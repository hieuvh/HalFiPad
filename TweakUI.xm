#import "TweakCommon.h"

// Bottom Inset
%hook UIWindow
- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets const x = %orig;
    return UIEdgeInsetsMake(x.top, x.left, bottomInset, x.right);
}
%end

%group FixInstagram
#include <sys/sysctl.h>
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
    bottomInset = 0;
    if (statusBarMode == 3) {
        %orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 6));
    }
    else {
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
        %orig(CGRectSetY(frame, frame.origin.y + 40));
    else
        %orig(CGRectSetY(frame, frame.origin.y + 20));
}
%end

@interface YTHeaderContentComboView : UIView
- (UIView*)headerView;
@end
%hook YTHeaderContentComboView
- (void)layoutSubviews {
    %orig;
    if (statusBarMode == 3) {
        CGRect headerViewFrame = [[self headerView] frame];
        headerViewFrame.origin.y += 18;
        [[self headerView] setFrame:headerViewFrame];
        [self setBackgroundColor:[[self headerView] backgroundColor]];
    }
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
#define keyy(key) CFEqual(string, CFSTR(key))
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
%ctor {
    @autoreleasepool {
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
                        bottomInset += 1;
                    else if (statusBarMode == 3 && appID(@"com.burbn.instagram"))
                        %init(FixInstagram);
                }

                if (appID(@"com.atebits.Tweetie2"))
                    %init(FixTwitter);
                else if (appID(@"com.apple.camera")) {
                    %init(CameraUISet);
                    if (isCameraBottomSet)
                        %init(CameraBottomSet);
                }

                if (screenMode == 0) {
                    if (appID(@"com.apple.weather")) return;
                    %init(iPadAppStyle);
                }
            }

            if (isPIP) %init(PictureInPicture);

            // Keyboard Options
            if (isDarkKeyboard)
                %init(DarkKeyBoard);

            if (isHigherKeyboard)
                %init(HigherKeyboard);
            else
                %init(DefaultKeyboard);

            %init;
        }
    }
}