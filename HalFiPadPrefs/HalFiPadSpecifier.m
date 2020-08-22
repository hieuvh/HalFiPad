#include "HalFiPadSpecifier.h"

#if __cplusplus
extern "C" {
#endif
    CFSetRef SBSCopyDisplayIdentifiers();
    NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
#if __cplusplus
}
#endif

static OrderedDictionary *dataSourceUser;

@implementation HalFiPadSpecifier
- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [self loadSpecifiersFromPlistName:@"HalFiPadAppCustomizationController" target:self];
        [testingSpecs addObjectsFromArray:[self appSpecifiers]];
        _specifiers = testingSpecs;
    }
	return _specifiers;
}

-(NSMutableArray*)appSpecifiers {
    NSMutableArray *specifiers = [NSMutableArray array];
    NSArray *displayIdentifiers = [(__bridge NSSet *)SBSCopyDisplayIdentifiers() allObjects];
    NSMutableDictionary *apps = [NSMutableDictionary new];

    for (NSString *appIdentifier in displayIdentifiers) {
        NSString *appName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appIdentifier);
        if (appName) {
            [apps setObject:appName forKey:appIdentifier];
        }
    }

    dataSourceUser = (OrderedDictionary*)[apps copy];
    dataSourceUser = (OrderedDictionary*)[self trimDataSource:dataSourceUser];
    dataSourceUser = [self sortedDictionary:dataSourceUser];

    for (NSString *bundleIdentifier in dataSourceUser.allKeys) {
        NSString *displayName = dataSourceUser[bundleIdentifier];

        PSSpecifier *spe = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:@selector(getIsWidgetSetForSpecifier:) detail:[HalFiPadAppCustomizationController class] cell:PSLinkListCell edit:nil];
        [spe setProperty:@"IBKWidgetSettingsController" forKey:@"detail"];
        [spe setProperty:[NSNumber numberWithBool:YES] forKey:@"isController"];
        [spe setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [spe setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
        [spe setProperty:bundleIdentifier forKey:@"appIDForLazyIcon"];
        [spe setProperty:@YES forKey:@"useLazyIcons"];

        [specifiers addObject:spe];
    }
    return specifiers;
}

-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource {
    NSMutableDictionary *mutable = [dataSource mutableCopy];
    return mutable;
}

-(OrderedDictionary*)sortedDictionary:(OrderedDictionary*)dict {
    NSArray *sortedValues;
    OrderedDictionary *mutable = [OrderedDictionary dictionary];
    sortedValues = [[dict allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *value in sortedValues) {
        NSString *key = [[dict allKeysForObject:value] objectAtIndex:0];
        [mutable setObject:value forKey:key];
    }
    return mutable;
}
@end