//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaExpression.h"

#import "NSObject-Extensions.h"

@interface MMFormulaExpression ()
@property (strong) MMFormulaNode *left;
@property (strong) MMFormulaNode *right;
@end

#pragma mark -

@implementation MMFormulaExpression
{
    MMFormulaOperation _operation;
    MMFormulaNode *_left;
    MMFormulaNode *_right;
}

- (id)init;
{
    if ((self = [super init])) {
        _operation = MMFormulaOperation_None;
        _left = nil;
        _right = nil;
    }

    return self;
}

#pragma mark -

- (id)operandOne;
{
    return self.left;
}

- (void)setOperandOne:(id)operand;
{
    self.left = operand;
}

- (id)operandTwo;
{
    return self.right;
}

- (void)setOperandTwo:(id)operand;
{
    self.right = operand;
}

- (NSString *)operationString;
{
    switch (self.operation) {
        default:
        case MMFormulaOperation_None:     return @"";
        case MMFormulaOperation_Add:      return @" + ";
        case MMFormulaOperation_Subtract: return @" - ";
        case MMFormulaOperation_Multiply: return @" * ";
        case MMFormulaOperation_Divide:   return @" / ";
    }

    return @"";
}

//
// Methods overridden from MMFormulaNode
//

- (NSUInteger)precedence;
{
    switch (self.operation) {
        case MMFormulaOperation_Add:
        case MMFormulaOperation_Subtract:
          return 1;

        case MMFormulaOperation_Multiply:
        case MMFormulaOperation_Divide:
          return 2;

        default:
            break;
    }

    return 0;
}

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols;
{
    switch (self.operation) {
        case MMFormulaOperation_Add:
            return [self.left evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols] + [self.right evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols];
            break;

        case MMFormulaOperation_Subtract:
            return [self.left evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols] - [self.right evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols];
            break;

        case MMFormulaOperation_Multiply:
            return [self.left evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols] * [self.right evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols];
            break;

        case MMFormulaOperation_Divide:
            return [self.left evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols] / [self.right evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols];
            break;

        default:
            return 1.0;
    }
    
    return 0.0;
}

- (NSInteger)maxPhone;
{
    NSUInteger max = 0;
    NSUInteger temp;

    temp = self.left.maxPhone;
    if (temp > max)
        max = temp;

    temp = self.right.maxPhone;
    if (temp > max)
        max = temp;

    return max + 1;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    BOOL shouldParenthesize = self.left.precedence < self.precedence;

    if (shouldParenthesize) {
        [resultString appendString:@"("];
        [self.left appendExpressionToString:resultString];
        [resultString appendString:@")"];
    } else {
        [self.left appendExpressionToString:resultString];
    }

    [resultString appendString:self.operationString];

    shouldParenthesize = self.right.precedence < self.precedence;

    if (shouldParenthesize) {
        [resultString appendString:@"("];
        [self.right appendExpressionToString:resultString];
        [resultString appendString:@")"];
    } else {
        [self.right appendExpressionToString:resultString];
    }
}

@end
