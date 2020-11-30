#import "HalFiPadSpecifier.h"
#import <SpringBoardServices/SBSRestartRenderServerAction.h>
#import <FrontBoardServices/FBSSystemService.h>

@implementation HalFiPadRootListController
- (instancetype)init {
    self = [super init];

    if (self) {
        self.enableSwitch = [[UISwitch alloc] init];
        self.enableSwitch.onTintColor = [UIColor colorWithRed: 0.45 green: 0.78 blue: 1.0 alpha: 1.0];
        [self.enableSwitch addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* switchy = [[UIBarButtonItem alloc] initWithCustomView: self.enableSwitch];
        self.navigationItem.rightBarButtonItem = switchy;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"HalFiPad";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HalFiPadPrefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

- (void)toggleState {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];

    if (![settings[@"Enabled"] boolValue]) {
        [settings setValue:[NSNumber numberWithBool:YES] forKey:@"Enabled"];
    } else {
        [settings setValue:[NSNumber numberWithBool:NO] forKey:@"Enabled"];
    }

    if ([settings writeToFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist" atomically:YES]) {
        [self respring];
    }
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        [testingSpecs addObjectsFromArray:[self groupSpec]];
        _specifiers = testingSpecs;
    }

	return _specifiers;
}

- (NSMutableArray*)groupSpec {
    NSMutableArray *specifiers = [NSMutableArray array];
    PSSpecifier* groupSpecifier = [
        PSSpecifier 
        preferenceSpecifierNamed:@"▷ Per-App Customization"
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

}

-(void)viewDidLoad {
	[super viewDidLoad];

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"]];
	NSNumber *didShowOBWelcomeController = [settings valueForKey:@"didShowOBWelcomeController"] ?: @0;
	if([didShowOBWelcomeController isEqual:@0]){
		[self setupWelcomeController];
	}

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.HalFiPadPrefs.plist"];
    if ([prefs[@"Enabled"] boolValue])
        [[self enableSwitch] setOn:YES animated:YES];
    else
        [[self enableSwitch] setOn:NO animated:YES];
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
}
@end