//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MPostureCategoryController.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation MPostureCategoryController
{
    IBOutlet NSTableView *_postureCategoryTableView;

    MModel *_model;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"PostureCategory"])) {
        _model = model;

        [self setWindowFrameAutosaveName:@"Posture Categories"];
    }

    return self;
}

#pragma mark -

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == _model)
        return;

    _model = newModel;

    [self updateViews];
    [self _selectFirstRow];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
#if 0
    NSNumberFormatter *defaultNumberFormatter;
    NSButtonCell *checkboxCell;
    MCommentCell *commentImageCell;

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[categoryOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    [checkboxCell release];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[categoryOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[parameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[metaParameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[symbolTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

    // InterfaceBuilder uses the first column in the nib as the outline column, so we need to rearrange them.
    [categoryOutlineView moveColumn:[categoryOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    //[categoryOutlineView moveColumn:[categoryOutlineView columnWithIdentifier:@"isUsed"] toColumn:1];

    [[[parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [categoryCommentTextView setFieldEditor:YES];
    [parameterCommentTextView setFieldEditor:YES];
    [metaParameterCommentTextView setFieldEditor:YES];
    [symbolCommentTextView setFieldEditor:YES];
#endif
    [self updateViews];
    [self _selectFirstRow];
}

- (void)updateViews;
{
    [self createCategoryColumns];
    [_postureCategoryTableView reloadData];
#if 0
    [categoryTotalTextField setIntValue:[[[self model] categories] count]];
    [parameterTotalTextField setIntValue:[[[self model] parameters] count]];
    [metaParameterTotalTextField setIntValue:[[[self model] metaParameters] count]];
    [symbolTotalTextField setIntValue:[[[self model] symbols] count]];

    [categoryOutlineView reloadData];
    [parameterTableView reloadData];
    [metaParameterTableView reloadData];
    [symbolTableView reloadData];

    [self _updateCategoryComment];
    [self _updateParameterComment];
    [self _updateMetaParameterComment];
    [self _updateSymbolComment];
#endif
}

- (void)createCategoryColumns;
{
    NSTableColumn *postureNameTableColumn;
    NSArray *tableColumns;
    NSUInteger count, index;
    NSMutableArray *categories;

    // Retain this column because we'll be removing it but want to add it back.
    postureNameTableColumn = [_postureCategoryTableView tableColumnWithIdentifier:@"name"];

    // Remove all the table columns
    tableColumns = [[NSArray alloc] initWithArray:[_postureCategoryTableView tableColumns]];
    count = [tableColumns count];
    for (index = 0; index < count; index++)
        [_postureCategoryTableView removeTableColumn:[tableColumns objectAtIndex:index]];

    // Add the posture name column back
    [_postureCategoryTableView addTableColumn:postureNameTableColumn];

    // Now we can add the category columns
    categories = [[self model] categories];
    count = [categories count];
    for (index = 0; index < count; index++) {
        NSTableColumn *newTableColumn;
        MMCategory *category;
        NSButtonCell *checkboxCell;

        category = [categories objectAtIndex:index];

        newTableColumn = [[NSTableColumn alloc] init];
        //[newTableColumn setIdentifier:[category symbol]];
        [newTableColumn setIdentifier:[category name]];
        [[newTableColumn headerCell] setTitle:[category name]];

        checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
        [checkboxCell setControlSize:NSSmallControlSize];
        [checkboxCell setButtonType:NSSwitchButton];
        [checkboxCell setImagePosition:NSImageOnly];
        [checkboxCell setEditable:NO];
        [newTableColumn setDataCell:checkboxCell];

        [newTableColumn sizeToFit];
        [_postureCategoryTableView addTableColumn:newTableColumn];
    }
}

- (void)_selectFirstRow;
{
    [_postureCategoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == _postureCategoryTableView)
        return [[[self model] postures] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == _postureCategoryTableView) {
        MMPosture *posture;

        posture = [[[self model] postures] objectAtIndex:row];
        if ([@"name" isEqual:identifier]) {
            return [posture name];
        } else {
            return [NSNumber numberWithBool:[posture isMemberOfCategoryNamed:identifier]];
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
}

#pragma mark - NSTableViewDelegate

- (BOOL)control:(NSControl *)control shouldProcessCharacters:(NSString *)characters;
{
    NSArray *postures;
    NSUInteger count, index;
    MMPosture *posture;

    postures = [[self model] postures];
    count = [postures count];
    for (index = 0; index < count; index++) {
        posture = [postures objectAtIndex:index];
        if ([[posture name] hasPrefix:characters]) {
            [_postureCategoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
            [_postureCategoryTableView scrollRowToVisible:index];
            return NO;
        }
    }

    return YES;
}

@end
