//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSCharacterSet-Extensions.h"

@implementation NSCharacterSet (Extensions)

+ (NSCharacterSet *)generalXMLEntityCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil)
        characterSet = [NSCharacterSet characterSetWithCharactersInString:@"&<>'\""];

    return characterSet;
}

+ (NSCharacterSet *)phoneStringWhitespaceCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"_"];
        characterSet = [aSet copy];
    }

    return characterSet;
}

+ (NSCharacterSet *)phoneStringIdentifierCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"^'#"];
        characterSet = [aSet copy];
    }

    return characterSet;
}

@end
