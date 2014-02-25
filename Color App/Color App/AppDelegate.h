//
//  AppDelegate.h
//  Color App
//
//  Created by Erica Sadun on 6/14/13.
//  Copyright (c) 2013 Erica Sadun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTextField *redField;
@property (weak) IBOutlet NSTextField *greenField;
@property (weak) IBOutlet NSTextField *blueField;
@property (weak) IBOutlet NSTextField *hexField;
@property (weak) IBOutlet NSColorWell *colorWell;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *colorNameLabel;
@property (weak) IBOutlet NSTextField *searchField;
@property (weak) IBOutlet NSView *nothingView;
@property (weak) IBOutlet NSTextField *rField;
@property (weak) IBOutlet NSTextField *bField;
@property (weak) IBOutlet NSTextField *gField;
@end
