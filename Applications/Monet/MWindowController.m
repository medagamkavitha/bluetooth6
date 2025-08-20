//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@implementation MWindowController
{
}

- (BOOL)isVisibleOnLaunch;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"VisibleOnLaunch %@", [self windowFrameAutosaveName]]];
}

- (void)setIsVisibleOnLaunch:(BOOL)flag;
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:[NSString stringWithFormat:@"VisibleOnLaunch %@", [self windowFrameAutosaveName]]];
}

- (void)saveWindowIsVisibleOnLaunch;
{
    // Don't load the window if it hasn't already been loaded.
    if ([self isWindowLoaded] && [[self window] isVisible])
        [self setIsVisibleOnLaunch:YES];
    else
        [self setIsVisibleOnLaunch:NO];
}

- (void)showWindowIfVisibleOnLaunch;
{
    if ([self isVisibleOnLaunch])
        [self showWindow:nil];
}

@end
