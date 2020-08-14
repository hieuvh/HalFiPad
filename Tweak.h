#import <UIKit/UIKit.h>

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)
#define pREFS [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"]
#define pATH @"/User/Library/Preferences/com.hius.HalFiPadPrefs.plist"
#define pATH_deFAULT @"/Library/PreferenceBundles/HalFiPadPrefs.bundle/defaults.plist"

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

NSInteger screenRound;
NSInteger appDockRound;
NSInteger bottomInset;

static int statusBarMode;
static int gesturesMode;
static int screenMode;

static int HomeBarWidth;
static int HomeBarHeight;
static int HomeBarRadius;

//iPad features
BOOL isFloatingDock;
BOOL isFloatingGesture;
BOOL isRecentApp;
BOOL isiPadMultitask;
BOOL isPIP;
BOOL isNewGridSwitcher;
//General
BOOL isHomeBarAutoHide;
BOOL isHomeBarSB;
BOOL isHomeBarLS;
BOOL isHomeBarCustom;
BOOL isCCStatusbar;
BOOL isCCGrabber;
BOOL isReachability;
BOOL isLSShortcuts;
BOOL isNoDockBackgroud;
BOOL isNoBreadcrumbs;
BOOL isiPXCombination;
//Battery Percent - BP
BOOL isBatteryPercent;
BOOL isDynamicColorBP;
BOOL isStaticColorBP;
BOOL isHideChargingIndicator;
BOOL isHideStockPercent;
BOOL isStockPercentCharging;
//Keyboard options
BOOL isHigherKeyboard;
BOOL isNoSwipeKeyboard;
BOOL isDarkKeyboard;
BOOL isNoGesturesKeyboard;
BOOL isNonLatinKeyboard;
//More options
BOOL isCameraUI11;
BOOL isCameraZoomFlip11;
BOOL isFastOpenApp;
BOOL isNoIconsFly;
BOOL isLandscapeLock;
BOOL isMakeClean;
BOOL isMoreIconDock;
BOOL isReduceRows;
BOOL isSwipeScreenshot;
BOOL isPadLock;

//Handle Preferences:
static BOOL boolValueForKey(NSString *key) {
    return [[pREFS objectForKey:key] boolValue];
}

static int intValueForKey(NSString *key) {
    return [[pREFS objectForKey:key] integerValue];
}

static void updatePrefs() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pATH]) {
       [fileManager copyItemAtPath:pATH_deFAULT toPath:pATH error:nil];
    }
    gesturesMode = intValueForKey(@"gesturesMode");
    statusBarMode = intValueForKey(@"statusBarMode");
    screenRound = intValueForKey(@"screenRound");
    appDockRound = intValueForKey(@"appDockRound");
    bottomInset = intValueForKey(@"bottomInset");
    screenMode = intValueForKey(@"screenMode");
    HomeBarWidth = intValueForKey(@"homeBarWidth");
    HomeBarHeight = intValueForKey(@"homeBarHeight");
    HomeBarRadius = intValueForKey(@"homeBarRadius");
    //iPad features:
    isFloatingDock = boolValueForKey(@"floatingDock");
    isiPadMultitask = boolValueForKey(@"iPadMultitask");
    isRecentApp = boolValueForKey(@"recentApp");
    isNewGridSwitcher = boolValueForKey(@"newSwitcher");
    isPIP = boolValueForKey(@"pictureInPicture");
    isFloatingGesture = boolValueForKey(@"floatingGesture");
    //General options:
    isCCStatusbar = boolValueForKey(@"ccStatusBar");
    isCCGrabber = boolValueForKey(@"ccGrabber");
    //HomeBar
    isHomeBarAutoHide = boolValueForKey(@"homeBarAutoHide");
    isHomeBarSB = boolValueForKey(@"homeBarSB");
    isHomeBarLS = boolValueForKey(@"homeBarLS");
    isHomeBarCustom = boolValueForKey(@"homeBarCustom");
    isLSShortcuts = boolValueForKey(@"lsShortcuts");
    isNoBreadcrumbs = boolValueForKey(@"noBreadcrumb");
    isReachability = boolValueForKey(@"noReachability");
    isiPXCombination = boolValueForKey(@"ipxCombination");
    //Battery Customization:
    isBatteryPercent = boolValueForKey(@"batteryPercent");
    isDynamicColorBP = boolValueForKey(@"dynamicColorBP");
    isStaticColorBP = boolValueForKey(@"staticColorBP");
    isHideChargingIndicator = boolValueForKey(@"hideChargingIndicator");
    isHideStockPercent = boolValueForKey(@"hideStockPercent");
    isStockPercentCharging = boolValueForKey(@"stockPercentCharging");
    //Keyboard options:
    isHigherKeyboard = boolValueForKey(@"highKeyboard");
    isDarkKeyboard = boolValueForKey(@"darkKeyboard");
    isNoSwipeKeyboard = boolValueForKey(@"noSwipeKeyboard");
    isNonLatinKeyboard = boolValueForKey(@"nonLatinKeyboard");
    // More options:
    isMakeClean = boolValueForKey(@"makeClean");
    isMoreIconDock = boolValueForKey(@"moreIconDock");
    isNoDockBackgroud = boolValueForKey(@"noDockBackground");
    isNoIconsFly = boolValueForKey(@"noIconsFly");
    isFastOpenApp = boolValueForKey(@"fastOpenApp");
    isCameraUI11 = boolValueForKey(@"cameraUI11");
    isCameraZoomFlip11 = boolValueForKey(@"cameraZoomFlip11");
    isSwipeScreenshot = boolValueForKey(@"swipeScreenshot");
    isLandscapeLock = boolValueForKey(@"landscapeLock");
    isReduceRows = boolValueForKey(@"reduceRows");
    isPadLock = boolValueForKey(@"padLock");
    //Per-App Customize
    NSString const *mainAppID = [NSBundle mainBundle].bundleIdentifier;
    NSDictionary const *appCustomize = [pREFS objectForKey:mainAppID];
    if (appCustomize) {
        screenMode = (NSInteger)[[appCustomize objectForKey:@"screenMode"]?:((NSNumber *)[NSNumber numberWithBool:screenMode]) integerValue];
        bottomInset = (NSInteger)[[appCustomize objectForKey:@"bottomInset"]?:((NSNumber *)[NSNumber numberWithBool:bottomInset]) integerValue];
        isDarkKeyboard = (BOOL)[[appCustomize objectForKey:@"darkKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isDarkKeyboard]) boolValue];
        isHigherKeyboard = (BOOL)[[appCustomize objectForKey:@"highKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isHigherKeyboard]) boolValue];
        isNonLatinKeyboard = (BOOL)[[appCustomize objectForKey:@"nonLatinKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:isNonLatinKeyboard]) boolValue];
    }
}