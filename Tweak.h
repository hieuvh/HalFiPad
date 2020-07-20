#import <UIKit/UIKit.h>

#define k(key) CFEqual(string, CFSTR(key))
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

static double ScreenRounded;
static CGFloat AppDockRounded;
NSInteger BottomInset;

static int StatusBarMode;
static int GesturesMode;
static int ScreenMode;

static int HomeBarWidth = 134;
static int HomeBarHeight = 5;
static int HomeBarRadius = 3;

//iPad features
BOOL FloatingDockEnabled;
BOOL FloatingGesturesEnabled;
BOOL RecentEnabled;
BOOL iPadMultitaskEnabled;
BOOL PIPEnabled;
BOOL NewGridSwitcherEnabled;
//General
BOOL HomeBarAutoHideEnabled;
BOOL HomeBarSBEnabled;
BOOL HomeBarLSEnabled;
BOOL HomeBarCustomEnabled;
BOOL CCStatusbarEnabled;
BOOL CCGrabberEnabled;
BOOL ReachabilityEnabled;
BOOL ShortcutsEnabled;
BOOL NoDockBackgroudEnabled;
BOOL NoBreadcrumbsEnabled;
BOOL XCombinationEnabled;
//Battery Custom
BOOL BatteryPercentEnabled;
BOOL DynamicColorBP;
BOOL StaticColor;
BOOL HideChargingIndicator;
BOOL HideStockPercentage;
BOOL StockPercentCharging;
//Keyboard options
BOOL HigherKeyboardEnabled;
BOOL NoSwipeKBEnabled;
BOOL DarkKeyBoardEnabled;
BOOL NoGesturesKeyboard;
BOOL NonLatinEnabled;
//More options
BOOL Cam11Enabled;
BOOL CamZoomFlipEnabled;
BOOL FastOpenEnabled;
BOOL NoIconsFlyEnabled;
BOOL LandscapeLockEnabled;
BOOL MakeCleanEnabled;
BOOL MoreIconDockEnabled;
BOOL ReduceRowsEnabled;
BOOL SwipeShotEnabled;
BOOL PadLockEnabled;

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
    GesturesMode = intValueForKey(@"gesturesMode");
    StatusBarMode = intValueForKey(@"statusBarMode");
    ScreenRounded = intValueForKey(@"screenRounded");
    AppDockRounded = intValueForKey(@"appDockRounded");
    BottomInset = intValueForKey(@"bottomInset");
    ScreenMode = intValueForKey(@"screenMode");
    HomeBarWidth = intValueForKey(@"homeBarWidth");
    HomeBarHeight = intValueForKey(@"homeBarHeight");
    HomeBarRadius = intValueForKey(@"homeBarRadius");
    //iPad features:
    FloatingDockEnabled = boolValueForKey(@"floatingDock");
    iPadMultitaskEnabled = boolValueForKey(@"enablediPadMultitask");
    RecentEnabled = boolValueForKey(@"recentApp");
    NewGridSwitcherEnabled = boolValueForKey(@"newSwitcher");
    PIPEnabled = boolValueForKey(@"pipEnable");
    FloatingGesturesEnabled = boolValueForKey(@"floatingGestures");
    //General options:
    CCStatusbarEnabled = boolValueForKey(@"ccStatusBar");
    CCGrabberEnabled = boolValueForKey(@"ccGrabber");
    //HomeBar
    HomeBarAutoHideEnabled = boolValueForKey(@"homeBarAutoHide");
    HomeBarSBEnabled = boolValueForKey(@"homeBarSB");
    HomeBarLSEnabled = boolValueForKey(@"homeBarLS");
    HomeBarCustomEnabled = boolValueForKey(@"homeBarCustom");
    ShortcutsEnabled = boolValueForKey(@"lsShortcuts");
    NoBreadcrumbsEnabled = boolValueForKey(@"noBreadcrumbs");
    ReachabilityEnabled = boolValueForKey(@"noReachability");
    XCombinationEnabled = boolValueForKey(@"xCombination");
    //Battery Customization:
    BatteryPercentEnabled = boolValueForKey(@"batteryPercent");
    StaticColor = boolValueForKey(@"staticColor");
    HideChargingIndicator = boolValueForKey(@"hideChargingIndicator");
    HideStockPercentage = boolValueForKey(@"hideStockPercent");
    StockPercentCharging = boolValueForKey(@"stockPercentCharging");
    DynamicColorBP = boolValueForKey(@"dynamicColorBatt");
    //Keyboard options:
    HigherKeyboardEnabled = boolValueForKey(@"highKeyboard");
    DarkKeyBoardEnabled = boolValueForKey(@"darkKeyboard");
    NoSwipeKBEnabled = boolValueForKey(@"noSwipeKeyboard");
    NonLatinEnabled = boolValueForKey(@"nonLatinKeyboard");
    // More options:
    MakeCleanEnabled = boolValueForKey(@"makeClean");
    MoreIconDockEnabled = boolValueForKey(@"moreIconDock");
    NoDockBackgroudEnabled = boolValueForKey(@"noDockBackground");
    NoIconsFlyEnabled = boolValueForKey(@"noIconsFly");
    FastOpenEnabled = boolValueForKey(@"fastOpenApp");
    Cam11Enabled = boolValueForKey(@"newCamUI");
    CamZoomFlipEnabled = boolValueForKey(@"camZoomFlip");
    SwipeShotEnabled = boolValueForKey(@"swipeShot");
    LandscapeLockEnabled = boolValueForKey(@"landscapeLock");
    ReduceRowsEnabled = boolValueForKey(@"reduceRows");
    PadLockEnabled = boolValueForKey(@"padLock");
    //Per-App Customize
    NSString const *mainAppID = [NSBundle mainBundle].bundleIdentifier;
    NSDictionary const *appCustomize = [pREFS objectForKey:mainAppID];
    if (appCustomize) {
        ScreenMode = (NSInteger)[[appCustomize objectForKey:@"screenMode"]?:((NSNumber *)[NSNumber numberWithBool:ScreenMode]) integerValue];
        BottomInset = (NSInteger)[[appCustomize objectForKey:@"bottomInset"]?:((NSNumber *)[NSNumber numberWithBool:BottomInset]) integerValue];
        DarkKeyBoardEnabled = (BOOL)[[appCustomize objectForKey:@"darkKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:DarkKeyBoardEnabled]) boolValue];
        HigherKeyboardEnabled = (BOOL)[[appCustomize objectForKey:@"highKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:HigherKeyboardEnabled]) boolValue];
        NonLatinEnabled = (BOOL)[[appCustomize objectForKey:@"nonLatinKeyboard"]?:((NSNumber *)[NSNumber numberWithBool:NonLatinEnabled]) boolValue];
    }
}