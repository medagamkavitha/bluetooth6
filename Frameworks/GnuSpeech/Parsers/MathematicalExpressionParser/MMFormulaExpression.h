//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaNode.h"

typedef enum : NSUInteger {
    MMFormulaOperation_None     = 0,
    MMFormulaOperation_Add      = 1,
    MMFormulaOperation_Subtract = 2,
    MMFormulaOperation_Multiply = 3,
    MMFormulaOperation_Divide   = 4,
} MMFormulaOperation;

@interface MMFormulaExpression : MMFormulaNode

@property (assign) MMFormulaOperation operation;

@property (strong) id operandOne;
@property (strong) id operandTwo;

@property (nonatomic, readonly) NSString *operationString;

// Methods overridden from MMFormulaNode
- (NSUInteger)precedence;

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols;

- (NSInteger)maxPhone;

@end
