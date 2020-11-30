#import "OrderedDictionary.h"

NSString *DescriptionForObject(NSObject *object, id locale, NSUInteger indent) {
	NSString *objectString;
	if ([object isKindOfClass:[NSString class]])
	{
		objectString = (NSString *)object;
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
	{
		objectString = [(NSDictionary *)object descriptionWithLocale:locale indent:indent];
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
	{
		objectString = [(NSSet *)object descriptionWithLocale:locale];
	}
	else
	{
		objectString = [object description];
	}
	return objectString;
}

@implementation OrderedDictionary
- (id)init {
	return [super initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity {
	self = [super init];
	if (self != nil)
	{
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		array = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

- (id)copy {
	return [self mutableCopy];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	if (![dictionary objectForKey:aKey]) {
		[array addObject:aKey];
	}
	[dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
	[dictionary removeObjectForKey:aKey];
	[array removeObject:aKey];
}

- (NSUInteger)count {
	return [dictionary count];
}

- (id)objectForKey:(id)aKey {
	return [dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
	return [array objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator {
	return [array reverseObjectEnumerator];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex {
	if ([dictionary objectForKey:aKey]) {
		[self removeObjectForKey:aKey];
	}
	[array insertObject:aKey atIndex:anIndex];
	[dictionary setObject:anObject forKey:aKey];
}

- (id)keyAtIndex:(NSUInteger)anIndex {
	return [array objectAtIndex:anIndex];
}
@end