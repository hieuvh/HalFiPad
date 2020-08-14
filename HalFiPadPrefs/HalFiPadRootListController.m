#import "AppCustomSpecifier.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#include <spawn.h>

@interface HalFiPadRootListController : PSListController
@property (nonatomic, retain) UIBarButtonItem *respringButton;
- (void)respring:(id)sender;
@end

@implementation HalFiPadRootListController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(respring:)];
        self.respringButton.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
        self.navigationItem.rightBarButtonItem = self.respringButton;
    }
    return self;
}

- (void)respring:(id)sender {
    pid_t pid;
    const char* args[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
        [testingSpecs addObjectsFromArray:[self groupSpec]];
        _specifiers = testingSpecs;
    }
	return _specifiers;
}

- (NSMutableArray*)groupSpec{
    NSMutableArray *specifiers = [NSMutableArray array];
    PSSpecifier* groupSpecifier = [PSSpecifier preferenceSpecifierNamed:@"‣ Per-App Customize"
                                               target:self
                                               set:nil
                                               get:@selector(getIsWidgetSetForSpecifier:)
                                               detail:[AppCustomSpecifier class]
                                               cell:PSLinkListCell
                                               edit:nil];
    [specifiers addObject:groupSpecifier];
    return specifiers;
}

- (void)openTwitter:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/helios017"] options:@{} completionHandler:nil];
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