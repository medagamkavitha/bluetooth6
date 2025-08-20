//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroup.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"
#import "MMEquation.h"
#import "MMTarget.h" // Just to get -appendXMLToString:level:, this is just a quick hack
#import "MMTransition.h"
#import "MMGroupedObject.h"

#import "GSXMLFunctions.h"

@interface MMGroup ()
@end

@implementation MMGroup
{
    NSMutableArray *_objects;
}

- (id)init;
{
    if ((self = [super init])) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"equation-group" isEqualToString:element.name] || [@"transition-group" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        self.model = model;

        _objects = [[NSMutableArray alloc] init];

        // This will have either equations or transitions, but not a mix.
        for (NSXMLElement *childElement in [element elementsForName:@"equation"]) {
            MMEquation *equation = [[MMEquation alloc] initWithXMLElement:childElement error:error];
            if (equation != nil) {
                [self addObject:equation];

                // Set the formula after adding it to the group, so that it has access to the model for the symbols
                NSString *str = [[childElement attributeForName:@"formula"] stringValue];
                if (str != nil && [str length] > 0)
                    [equation setFormulaString:str];
            }
        }

        for (NSXMLElement *childElement in [element elementsForName:@"transition"]) {
            MMTransition *transition = [[MMTransition alloc] initWithModel:model XMLElement:childElement error:error];
            if (transition != nil) {
                [self addObject:transition];
            }
        }
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, objects: %@",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.objects];
}

#pragma mark -

- (NSArray *)objects;
{
    return [_objects copy];
}

- (void)setModel:(MModel *)newModel;
{
    [super setModel:newModel];
    
    for (id currentObject in self.objects) {
        if ([currentObject respondsToSelector:@selector(setModel:)])
            [currentObject setModel:newModel];
    }
}

- (void)addObject:(MMGroupedObject *)object;
{
    NSParameterAssert(self.model != nil);
    [_objects addObject:object];

    object.model = self.model;
    object.group = self;
}

- (id)objectWithName:(NSString *)name;
{
    for (MMNamedObject *object in _objects) {
        if ([name isEqualToString:object.name])
            return object;
    }
    
    return nil;
}

#pragma mark - XML Archiving

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    NSUInteger count = [self.objects count];
    if (count == 0)
        return;
    
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@ name=\"%@\"", elementName, GSXMLAttributeString(self.name, NO)];
    
    if (self.comment != nil)
        [resultString appendFormat:@" comment=\"%@\"", GSXMLAttributeString(self.comment, NO)];
    
    [resultString appendString:@">\n"];
    
    for (NSUInteger index = 0; index < count; index++) {
        id anObject = [self.objects objectAtIndex:index];
        [anObject appendXMLToString:resultString level:level+1];
    }
    
    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
