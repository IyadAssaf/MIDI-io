//
//  AppDelegate.h
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MidiIO.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, MidiIODelegate>
{
    MidiIO *midi;
    
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *inputDevice;
@property (weak) IBOutlet NSTextFieldCell *outputDevice;

- (IBAction)listInputDevices:(id)sender;

- (IBAction)listOutputDevices:(id)sender;

@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSTextField *monitor;

@end
