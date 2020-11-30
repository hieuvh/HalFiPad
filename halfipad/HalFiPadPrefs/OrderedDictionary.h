@import UIKit;
@interface OrderedDictionary : NSMutableDictionary {
	NSMutableDictionary *dictionary;
	NSMutableArray *array;
}
- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex;
- (id)keyAtIndex:(NSUInteger)anIndex;
- (NSEnumerator *)reverseKeyEnumerator;
@end