//
//  AppDelegate.m
//  Color App
//
//  Created by Erica Sadun on 6/14/13.
//  Copyright (c) 2013 Erica Sadun. All rights reserved.
//

#import "AppDelegate.h"
#import "NSColorUtils.h"

@implementation AppDelegate
{
    NSColor *currentColor;
    BOOL ignoreColorWellUpdate;
    NSArray *items;
    NSTableView *tableView;
}

- (void) updateRGBValues
{
    _redField.stringValue = @((int) (currentColor.red * 255.0f)).stringValue;
    _greenField.stringValue = @((int) (currentColor.green * 255.0f)).stringValue;
    _blueField.stringValue = @((int) (currentColor.blue * 255.0f)).stringValue;
    
    _rField.stringValue = [NSString stringWithFormat:@"%0.3f", currentColor.red];
    _gField.stringValue = [NSString stringWithFormat:@"%0.3f", currentColor.green];
    _bField.stringValue = [NSString stringWithFormat:@"%0.3f", currentColor.blue];
}

- (void) updateHexValue
{
    _hexField.stringValue = currentColor.hexStringValue;
}

- (void) updateColor
{
    [[NSUserDefaults standardUserDefaults] setObject:currentColor.hexStringValue forKey:@"colorKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _colorNameLabel.stringValue = [currentColor.closestColorName capitalizedString];
    
    ignoreColorWellUpdate = YES;
    _colorWell.color = currentColor;
    ignoreColorWellUpdate = NO;
}

- (void) calculateFromFloatRGB
{
    CGFloat r = _rField.stringValue.floatValue;
    CGFloat g = _gField.stringValue.floatValue;
    CGFloat b = _bField.stringValue.floatValue;
    
    r = MIN(MAX(r, 0.0f), 1.0f);
    g = MIN(MAX(g, 0.0f), 1.0f);
    b = MIN(MAX(b, 0.0f), 1.0f);

    _rField.stringValue = [NSString stringWithFormat:@"%0.3f", r];
    _gField.stringValue = [NSString stringWithFormat:@"%0.3f", g];
    _bField.stringValue = [NSString stringWithFormat:@"%0.3f", b];
    
    currentColor = [NSColor colorWithDeviceRed:r green:g blue:b alpha:1];
    
    [self updateColor];
    [self updateHexValue];
}

- (void) calculateFromRGB
{
    CGFloat r = _redField.stringValue.floatValue;
    CGFloat g = _greenField.stringValue.floatValue;
    CGFloat b = _blueField.stringValue.floatValue;
    
    // Are any out of range?
    if (r < 0)
    {
        r *= -1;
        _redField.stringValue = @(r).stringValue;
    }
    
    if (g < 0)
    {
        g *= -1;
        _greenField.stringValue = @(g).stringValue;
    }
    
    if (b < 0)
    {
        b *= -1;
        _blueField.stringValue = @(b).stringValue;
    }
    
    if (r > 255)
    {
        r = 255;
        _redField.stringValue = @(r).stringValue;
    }
    
    if (g > 255)
    {
        g = 255;
        _greenField.stringValue = @(g).stringValue;
    }
    
    if (b > 255)
    {
        b = 255;
        _blueField.stringValue = @(b).stringValue;
    }

    currentColor = [NSColor colorWithDeviceRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1];
    
    [self updateColor];
    [self updateHexValue];
}

- (void) calculateFromHex
{
    NSColor *provisionalColor = [NSColor colorWithHexString:_hexField.stringValue];
    if (!provisionalColor)
        _hexField.stringValue = currentColor.hexStringValue;
    else
        currentColor = provisionalColor;
    [self updateColor];
    [self updateRGBValues];
}

- (void) updateSearch
{
    NSArray *components = [_searchField.stringValue componentsSeparatedByString:@" "];
    items = [NSColor closeColorNamesMatchingKeys:components];
    if (_searchField.stringValue.length == 0)
        items = [NSColor colorNames];
    [tableView reloadData];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSTextField *field = aNotification.object;
    if ((field == _redField) | (field == _greenField) | (field == _blueField))
        [self calculateFromRGB];
    else if (field == _hexField)
        [self calculateFromHex];
    else if (field == _searchField)
        [self updateSearch];
    else if ((field == _rField) | (field == _gField) | (field == _bField))
        [self calculateFromFloatRGB];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"color"])
    {
        if (ignoreColorWellUpdate)
        {
        }
        else
        {
            currentColor = _colorWell.color;
            [self updateColor];
            [self updateHexValue];
            [self updateRGBValues];
         }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return items.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return items[rowIndex];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSString *name = items[rowIndex];
    NSColor *color = [NSColor colorWithName:name];
    if (color)
    {
        currentColor = color;
        _hexField.stringValue = currentColor.hexStringValue;
        _colorNameLabel.stringValue = [items[rowIndex] capitalizedString];
        [self updateRGBValues];
        
        [[NSUserDefaults standardUserDefaults] setObject:currentColor.hexStringValue forKey:@"colorKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        ignoreColorWellUpdate = YES;
        _colorWell.color = currentColor;
        ignoreColorWellUpdate = NO;
    }
    return YES;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *colorString = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorKey"];
    currentColor = colorString ? [NSColor colorWithHexString:colorString] : [NSColor redColor];
    [_colorWell addObserver:self forKeyPath:@"color" options:0 context:nil];
    ignoreColorWellUpdate = NO;
    [self updateColor];
    [self updateHexValue];
    [self updateRGBValues];
    
    _searchField.stringValue = @"";
    items = [NSColor colorNames];
    
    // create table
    tableView = [[NSTableView alloc] initWithFrame:CGRectInset(_nothingView.frame, 4, 4)];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"id"];
    column.width = _nothingView.frame.size.width;
    [column.headerCell setStringValue:@" Matching Colors"];
    [tableView addTableColumn:column];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:_nothingView.frame];
    scrollView.documentView = tableView;
    scrollView.hasVerticalScroller = YES;

    [_window.contentView addSubview:scrollView];
}
@end
