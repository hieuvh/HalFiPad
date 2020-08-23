#import "HeaderListPrefs.h"

@interface PSListController (hideOption)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface HomeBarListPrefs : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end

@implementation HomeBarListPrefs
- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"CustomHomeBar" target:self];
        _specifiers = testingSpecs;
    }

    NSArray *chosenIDs = @[@"widthID", @"widthID2", @"heightID", @"heightID2", @"radiusID", @"radiusID2"];
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
    if(![prefs[@"homeBarCustom"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID2"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID2"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID2"]] animated:YES];
    }
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"homeBarCustom"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID2"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID2"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID2"]] animated:NO];
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
    if([key isEqualToString:@"homeBarCustom"]) {
        if(![value boolValue]) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"widthID2"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightID2"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID2"]] animated:YES];
        } else {
            if(![self containsSpecifier:self.savedSpecifiers[@"widthID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"widthID"]] afterSpecifierID:@"sizeCustomID" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"widthID2"]] afterSpecifierID:@"widthID" animated:YES];
            }
            if(![self containsSpecifier:self.savedSpecifiers[@"heightID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"heightID"]] afterSpecifierID:@"widthID2" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"heightID2"]] afterSpecifierID:@"heightID" animated:YES];
            }
            if(![self containsSpecifier:self.savedSpecifiers[@"radiusID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID"]] afterSpecifierID:@"heightID2" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"radiusID2"]] afterSpecifierID:@"radiusID" animated:YES];
            }
        }
    }
}
@end