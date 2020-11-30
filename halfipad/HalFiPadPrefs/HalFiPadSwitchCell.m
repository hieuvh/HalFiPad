#import <Preferences/PSSwitchTableCell.h>

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