#import "HeaderListPrefs.h"
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSEditableTableCell.h>

@interface PSEditableTableCell (Interface)
- (id)textField;
@end

@interface BatteryListPrefs : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@property(nonatomic, retain)UISwitch* enableSwitch;
@end

@implementation BatteryListPrefs
- (instancetype)init {
    self = [super init];

    if (self) {
        self.enableSwitch = [[UISwitch alloc] init];
        self.enableSwitch.onTintColor = [UIColor colorWithRed: 0.45 green: 0.78 blue: 1.0 alpha: 1.0];
        [self.enableSwitch addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* switchy = [[UIBarButtonItem alloc] initWithCustomView: self.enableSwitch];
        self.navigationItem.rightBarButtonItem = switchy;
    }
    return self;
}

- (void)toggleState {
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];

    if (![settings[@"batteryPercent"] boolValue]) {
        [self toggleCellState:YES];
        [settings setValue:[NSNumber numberWithBool:YES] forKey:@"batteryPercent"];
    } else {
        [self toggleCellState:NO];
        [settings setValue:[NSNumber numberWithBool:NO] forKey:@"batteryPercent"];
    }
    [settings writeToFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist" atomically:YES];
}

- (void)toggleCellState:(BOOL)enable {
    if (enable) {
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] enabled:YES];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] enabled:YES];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] enabled:YES];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] enabled:YES];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] enabled:YES];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] enabled:YES];
    } else {
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] enabled:NO];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] enabled:NO];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] enabled:NO];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] enabled:NO];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] enabled:NO];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] enabled:NO];
    }
}

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {

    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];

    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control)
                controlCell.control.enabled = enabled;
        } else if ([cell isKindOfClass:[PSEditableTableCell class]]) {
            PSEditableTableCell *editableCell = (PSEditableTableCell *)cell;
            ((UITextField*)[editableCell textField]).alpha = enabled ? 1 : 0.4;
        }
    }
}

-(void)viewDidLoad {
	[super viewDidLoad];

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];

    if ([prefs[@"batteryPercent"] boolValue]) {
        [self toggleCellState:YES];
        [[self enableSwitch] setOn:YES animated:YES];
    } else {
        [self toggleCellState:NO];
        [[self enableSwitch] setOn:NO animated:YES];
    }

    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];

    if ([settings[@"percentChargingCC"] boolValue]) {
        [settings setValue:[NSNumber numberWithBool:NO] forKey:@"hideStockPercent"];
        [settings writeToFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist" atomically:YES];
    }
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"CustomBattery" target:self];
        _specifiers = testingSpecs;
    }
	return _specifiers;
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
}
@end