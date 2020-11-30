#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>

@interface PSListController (hideOption)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface KeyboardListPrefs : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end

@implementation KeyboardListPrefs
- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"KeyboardOptions" target:self];
        _specifiers = testingSpecs;
    }

    NSArray *chosenIDs = @[@"heightKbID", @"heightKbID2", @"boundKbID", @"boundKbID2"];
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
    if(![prefs[@"highKeyboard"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID2"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID2"]] animated:YES];
    }
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"highKeyboard"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID2"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID2"]] animated:NO];
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
    if([key isEqualToString:@"highKeyboard"]) {
        if(![value boolValue]) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID2"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID2"]] animated:YES];
        } else {
            if(![self containsSpecifier:self.savedSpecifiers[@"heightKbID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID"]] afterSpecifierID:@"highKbID" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"heightKbID2"]] afterSpecifierID:@"heightKbID" animated:YES];
            }

            if(![self containsSpecifier:self.savedSpecifiers[@"boundKbID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID"]] afterSpecifierID:@"heightKbID2" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"boundKbID2"]] afterSpecifierID:@"boundKbID" animated:YES];
            }
        }
    }
}
@end