@import UIKit;

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

typedef struct SBIconCoordinate {
    NSInteger row;
    NSInteger col;
} SBIconCoordinate;

//Gestures
@interface SBHomeGesturePanGestureRecognizer
-(void)reset;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2;
@end

//Lockscreen shortcuts
@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton;
@property (nonatomic, retain) UIControl *cameraButton;
@end

NSInteger screenRound, appDockRound, bottomInset;
NSInteger HomeBarWidth, HomeBarHeight, HomeBarRadius;
static NSInteger KeyboardHeight = 48, KeyboardBound = -15;

short statusBarMode, gesturesMode, screenMode, batteryColorMode;

BOOL enabled;
//iPad features
BOOL isiPadDock, isInAppDock, isRecentApp;
BOOL isiPadMultitask, isPIP, isNewGridSwitcher;

//General
BOOL isEdgeProtect, isHomeBarAutoHide, isHomeBarSB, isHomeBarLS, isHomeBarCustom;
BOOL isCCStatusbar, isCCGrabber, isCCAnimation, isNoBreadcrumb;
BOOL isiPXCombination, isReachability, isLSShortcuts, isPadLock;

//Battery Percent - BP
BOOL isBatteryPercent, isPercentChargingCC;
BOOL isHideChargingIndicator, isHideStockPercent;

//Keyboard options
BOOL isHigherKeyboard, isDarkKeyboard, isNonLatinKeyboard;
BOOL isNoSwipeKeyboard, isNoGesturesKeyboard;

//Camera Options
BOOL isCameraBottomSet, isCameraUI11, isCameraZoomFlip11;

//More options
BOOL isFastOpenApp, isNoIconsFly, isLandscapeLock, isNoDockBackgroud;
BOOL isMakeSBClean, isMoreIconDock, isReduceRows, isSwipeScreenshot;

//Handle Preferences:
static BOOL boolValueForKey(NSString *key) {
    NSDictionary const *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    return [[prefs objectForKey:key] boolValue];
}

static int intValueForKey(NSString *key) {
    NSDictionary const *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    return [[prefs objectForKey:key] integerValue];
}

static void updatePrefs() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:@"/User/Library/Preferences/com.hius.HalFiPadPrefs.plist"]) {
        [fileManager copyItemAtPath:@"/Library/PreferenceBundles/HalFiPadPrefs.bundle/defaults.plist" toPath:@"/User/Library/Preferences/com.hius.HalFiPadPrefs.plist" error:nil];
    }
    NSDictionary const *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if (prefs) {
        enabled = boolValueForKey(@"Enabled");
        batteryColorMode = intValueForKey(@"batteryColorMode");
        gesturesMode = intValueForKey(@"gesturesMode");
        statusBarMode = intValueForKey(@"statusBarMode");
        screenMode = intValueForKey(@"screenMode");
        screenRound = intValueForKey(@"screenRound");
        appDockRound = intValueForKey(@"roundAppDock");
        bottomInset = intValueForKey(@"bottomInset");
        HomeBarWidth = intValueForKey(@"homeBarWidth");
        HomeBarHeight = intValueForKey(@"homeBarHeight");
        HomeBarRadius = intValueForKey(@"homeBarRadius");
        KeyboardHeight = intValueForKey(@"bottomHeightKB");
        KeyboardBound = intValueForKey(@"boundKeyboard");
        //iPad features:
        isiPadDock = boolValueForKey(@"ipadDock");
        isiPadMultitask = boolValueForKey(@"iPadMultitask");
        isRecentApp = boolValueForKey(@"recentApp");
        isNewGridSwitcher = boolValueForKey(@"newSwitcher");
        isPIP = boolValueForKey(@"pictureInPicture");
        isInAppDock = boolValueForKey(@"inAppDock");
        //General options:
        isCCAnimation = boolValueForKey(@"ccAnimation");
        isCCStatusbar = boolValueForKey(@"ccStatusBar");
        isCCGrabber = boolValueForKey(@"ccGrabber");
        //HomeBar
        isEdgeProtect = boolValueForKey(@"edgeProtect");
        isHomeBarAutoHide = boolValueForKey(@"homeBarAutoHide");
        isHomeBarSB = boolValueForKey(@"homeBarSB");
        isHomeBarLS = boolValueForKey(@"homeBarLS");
        isHomeBarCustom = boolValueForKey(@"homeBarCustom");
        isLSShortcuts = boolValueForKey(@"lsShortcuts");
        isNoBreadcrumb = boolValueForKey(@"noBreadcrumb");
        isReachability = boolValueForKey(@"noReachability");
        isiPXCombination = boolValueForKey(@"ipxCombination");
        //Battery Customization:
        isBatteryPercent = boolValueForKey(@"batteryPercent");
        isHideChargingIndicator = boolValueForKey(@"hideChargingIndicator");
        isHideStockPercent = boolValueForKey(@"hideStockPercent");
        isPercentChargingCC = boolValueForKey(@"percentChargingCC");
        //Keyboard options:
        isHigherKeyboard = boolValueForKey(@"highKeyboard");
        isDarkKeyboard = boolValueForKey(@"darkKeyboard");
        isNoSwipeKeyboard = boolValueForKey(@"noSwipeKeyboard");
        isNonLatinKeyboard = boolValueForKey(@"nonLatinKeyboard");
        // More options:
        isMakeSBClean = boolValueForKey(@"makeSBClean");
        isMoreIconDock = boolValueForKey(@"moreIconDock");
        isNoDockBackgroud = boolValueForKey(@"noDockBackground");
        isNoIconsFly = boolValueForKey(@"noIconsFly");
        isFastOpenApp = boolValueForKey(@"fastOpenApp");
        isCameraBottomSet = boolValueForKey(@"cameraBottomSet");
        isCameraUI11 = boolValueForKey(@"cameraUI11");
        isCameraZoomFlip11 = boolValueForKey(@"cameraZoomFlip11");
        isSwipeScreenshot = boolValueForKey(@"swipeScreenshot");
        isLandscapeLock = boolValueForKey(@"landscapeLock");
        isReduceRows = boolValueForKey(@"reduceRows");
        isPadLock = boolValueForKey(@"padLock");
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