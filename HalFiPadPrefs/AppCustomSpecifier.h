#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "OrderedDictionary.h"

@interface AppCustomSpecifier : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource;
-(NSMutableArray*)appSpecifiers;
@end

@interface HalFiPadAppCustomizationController : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
@end