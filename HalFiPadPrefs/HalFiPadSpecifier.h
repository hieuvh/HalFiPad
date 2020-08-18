#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import "OrderedDictionary.h"

@interface HalFiPadSpecifier : PSListController
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

@interface HalFiPadRootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@property (nonatomic, retain) UIBarButtonItem *respringButton;
@end

@interface PSListController (WD)
-(BOOL)containsSpecifier:(id)arg1;
@end