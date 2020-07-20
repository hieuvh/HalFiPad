#include "AppCustomSpecifier.h"

@implementation HalFiPadAppCustomizationController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(id)specifiers {
    if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"AppCustomization" target:self] mutableCopy];
        _specifiers = testingSpecs;
    }
	return _specifiers;
}

-(void)setSpecifier:(PSSpecifier*)specifier {
    [super setSpecifier:specifier];
    self.displayName = [specifier name];
    self.bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	NSMutableDictionary *appCustom = [settings objectForKey:self.bundleIdentifier];
	if (!appCustom) {
		appCustom = [NSMutableDictionary new];
	}
	return ([appCustom objectForKey:specifier.properties[@"key"]]) ?: [settings objectForKey:specifier.properties[@"key"]]?:specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	if (![settings objectForKey:self.bundleIdentifier]) {
		[settings setObject:[NSMutableDictionary new] forKey:self.bundleIdentifier];
	}

	[(NSMutableDictionary *)[settings valueForKey:self.bundleIdentifier] setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];

	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}
@end