#import "HalFiPadSpecifier.h"
#import <Preferences/PSSwitchTableCell.h>
#import <SpringBoardServices/SBSRestartRenderServerAction.h>
#import <FrontBoardServices/FBSSystemService.h>

@interface HalFiPadSwitchCell : PSSwitchTableCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end

@implementation HalFiPadSwitchCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed: 0.45 green: 0.78 blue: 1.0 alpha: 1.0]]; 
    }
    return self;
}
@end

@implementation HalFiPadListControler
- (id)specifiers {
    return _specifiers;
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString *sub = [specifier propertyForKey:@"LinkPrefs"];
    NSString *title = [specifier name];

    _specifiers = [self loadSpecifiersFromPlistName:sub target:self];

    [self setTitle:title];
    [self.navigationItem setTitle:title];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];
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

OBWelcomeController *welcomeController;

@implementation HalFiPadRootListController

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];//[[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
        [testingSpecs addObjectsFromArray:[self groupSpec]];
        _specifiers = testingSpecs;
    }

    NSArray *chosenIDs = @[@"heightKeyboardID", @"boundKeyboardID"];
    self.savedSpecifiers = [[NSMutableDictionary alloc] init];
    for(PSSpecifier *specifier in _specifiers) {
        if([chosenIDs containsObject:[specifier propertyForKey:@"id"]]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

	return _specifiers;
}

- (NSMutableArray*)groupSpec {
    NSMutableArray *specifiers = [NSMutableArray array];
    PSSpecifier* groupSpecifier = [
        PSSpecifier 
        preferenceSpecifierNamed:@"‣ Per-App Customize"
        target:self
        set:nil
        get:@selector(getIsWidgetSetForSpecifier:)
        detail:[HalFiPadSpecifier class]
        cell:PSLinkListCell
        edit:nil
    ];
    [specifiers addObject:groupSpecifier];
    return specifiers;
}

-(void)setupWelcomeController {
    welcomeController = [[OBWelcomeController alloc] initWithTitle:@"Welcome to HalFiPad" detailText:@"Bring modern gestures and many unique features to your device." icon:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HalFiPadPrefs.bundle/icon.png"]];

    [welcomeController addBulletedListItemWithTitle:@"Support" description:@"Applications and tweaks are fully supported." image:[UIImage systemImageNamed:@"rectangle.3.offgrid"]];
    [welcomeController addBulletedListItemWithTitle:@"Convenient" description:@"Built to fulfill its purpose easily." image:[UIImage systemImageNamed:@"tray.full.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Optimized" description:@"Lightweight and less battery drain." image:[UIImage systemImageNamed:@"battery.100"]];
    [welcomeController addBulletedListItemWithTitle:@"Open Source" description:@"HalFiPad is open source. Enjoy it!" image:[UIImage systemImageNamed:@"chevron.left.slash.chevron.right"]];
    [welcomeController.buttonTray addCaptionText:@"Made by Hius."];

    OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Let's Go" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.layer setCornerRadius:15];
    [welcomeController.buttonTray addButton:continueButton];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    welcomeController.modalInPresentation = YES;
    welcomeController.view.tintColor = [UIColor colorWithRed: 0.45 green: 0.78 blue: 1.0 alpha: 1.0];
    [self presentViewController:welcomeController animated:YES completion:nil];
}

- (void)respring {
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [blurView setFrame:self.view.bounds];
    [blurView setAlpha:0.0];
    [[self view] addSubview:blurView];

    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:1.0];
    } completion:^(BOOL finished) {
        NSURL *returnURL = [NSURL URLWithString:@"prefs:root=HalFiPad"];
        SBSRelaunchAction *restartAction;
        restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchActionOptionsFadeToBlackTransition targetURL:returnURL];
        [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
    }];
}

- (void)respringPrompt {
	UIAlertController *respringAlert = [UIAlertController alertControllerWithTitle:@"HalFiPad"
	message:@"Do you want to Respring?"
	preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		[self respring];
	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[respringAlert addAction:confirmAction];
	[respringAlert addAction:cancelAction];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

-(void)resetSetting {
    if([[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist" error: nil]) {
        [self respring];
    }
}

- (void)resetPrompt {
	UIAlertController *respringAlert = [UIAlertController alertControllerWithTitle:@"HalFiPad"
	message:@"Do you want to Reset?"
	preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		[self resetSetting];
	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[respringAlert addAction:confirmAction];
	[respringAlert addAction:cancelAction];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

-(void)openTwitter:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/helios017"] options:@{} completionHandler:nil];
}

-(void)viewDidLoad {
	[super viewDidLoad];

    UIBarButtonItem *respringButton = [
        [UIBarButtonItem alloc]
        initWithTitle:@"Apply"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(respringPrompt)];
	self.navigationItem.rightBarButtonItem = respringButton;

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"]];
	NSNumber *didShowOBWelcomeController = [settings valueForKey:@"didShowOBWelcomeController"] ?: @0;
	if([didShowOBWelcomeController isEqual:@0]){
		[self setupWelcomeController];
	}

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"highKeyboard"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKeyboardID"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKeyboardID"]] animated:YES];
    }
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if(![prefs[@"highKeyboard"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKeyboardID"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKeyboardID"]] animated:NO];
    }
}

-(void)dismissWelcomeController {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"]];
	[settings setObject:@1 forKey:@"didShowOBWelcomeController"];
	[settings writeToFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist" atomically:YES];
	[welcomeController dismissViewControllerAnimated:YES completion:nil];
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
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"heightKeyboardID"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"boundKeyboardID"]] animated:YES]; 
        } else {
            if(![self containsSpecifier:self.savedSpecifiers[@"heightKeyboardID"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"heightKeyboardID"]] afterSpecifierID:@"higherKeyboardID" animated:YES];
                if(![self containsSpecifier:self.savedSpecifiers[@"boundKeyboardID"]]) {
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"boundKeyboardID"]] afterSpecifierID:@"heightKeyboardID" animated:YES];
                }
            }
            
        }
    }
}
@end