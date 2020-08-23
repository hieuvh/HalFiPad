#import "HeaderListPrefs.h"
#import "OrderedDictionary.h"

@interface PSListController (WelcomeDisplay)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface HalFiPadSpecifier : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource;
-(NSMutableArray*)appSpecifiers;
@end

@interface HalFiPadRootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@property(nonatomic, retain)UISwitch* enableSwitch;
@end

@interface HalFiPadAppCustomizationController : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
@end

@interface OBButtonTray : UIView
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

OBWelcomeController *welcomeController;