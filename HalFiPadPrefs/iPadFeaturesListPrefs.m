#import "HeaderListPrefs.h"

@interface iPadFeaturesListPrefs : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end

@interface PSListController (hideOption)
-(BOOL)containsSpecifier:(id)arg1;
@end

@implementation iPadFeaturesListPrefs
- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"iPadFeatures" target:self];
        _specifiers = testingSpecs;
    }

	NSArray *chosenIDs = @[@"InAppID", @"RecentAppID", @"SplitViewID"];
    self.savedSpecifiers = [[NSMutableDictionary alloc] init];
    for(PSSpecifier *specifier in _specifiers) {
        if([chosenIDs containsObject:[specifier propertyForKey:@"id"]]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

	return _specifiers;
}

-(void)viewDidLoad {
	[super viewDidLoad];

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"ipadDock"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"InAppID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"RecentAppID"]] animated:YES];
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"SplitViewID"]] animated:YES];
    }
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"ipadDock"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"InAppID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"RecentAppID"]] animated:NO];
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"SplitViewID"]] animated:NO];
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}

	NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"ipadDock"]) {
        if(![value boolValue]) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"InAppID"]] animated:YES];
        	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"RecentAppID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"SplitViewID"]] animated:YES];
        } else {
            if(![self containsSpecifier:self.savedSpecifiers[@"InAppID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"InAppID"]] afterSpecifierID:@"iPadDockID" animated:YES];
            }
            if(![self containsSpecifier:self.savedSpecifiers[@"RecentAppID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"RecentAppID"]] afterSpecifierID:@"InAppID" animated:YES];
            }
			if(![self containsSpecifier:self.savedSpecifiers[@"SplitViewID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"SplitViewID"]] afterSpecifierID:@"AppID" animated:YES];
            }
        }
    }
}
@end