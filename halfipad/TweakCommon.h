#import <UIKit/UIKit.h>

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

NSInteger statusBarMode, screenMode;

//Handle Preferences:
static int intValueForKey(NSString *key, NSDictionary const *prefs) {
    return [[prefs objectForKey:key] integerValue];
}

static bool boolValueForKey(NSString *key, NSDictionary const *prefs) {
    return [[prefs objectForKey:key] boolValue];
}

//Enable Tweak
BOOL enabled;