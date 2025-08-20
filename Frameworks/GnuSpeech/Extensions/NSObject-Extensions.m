//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSObject-Extensions.h"

@implementation NSObject (Extensions)

- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self];
}

@end
