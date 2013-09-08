//
//  AppDelegate.m
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    midi = [[MidiIO alloc] init];
    
    [midi addOutputDevice:@"Launchpad"];
    
    
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [midi disposeInputDevices];
    [midi disposeOutputDevices];
    
    
}

- (IBAction)listInputDevices:(id)sender {
    
    NSArray *inputDevices = [midi inputDevices];
    self.label.stringValue = @"";
    
    for(int i=0; i<inputDevices.count; i++)
    {
        self.label.stringValue = [self.label.stringValue stringByAppendingString:[NSString stringWithFormat:@"\n %d: %@", i, [inputDevices objectAtIndex:i]]];
    }

//    [midi sendMIDINote];

    for(int i=0; i<127; i++)
    {
        [midi sendNote:i :67];
    }
    
    for(int i=0; i<127; i++)
    {
        [midi sendNote:i :42];
    }
    
    
    
//    [midi clear];
    
}

- (IBAction)listOutputDevices:(id)sender {
    
    NSArray *outputDevices = [midi outputDevices];
    self.label.stringValue = @"";
    
    for(int i=0; i<outputDevices.count; i++)
    {        
        self.label.stringValue = [self.label.stringValue stringByAppendingString:[NSString stringWithFormat:@"\n %d: %@", i, [outputDevices objectAtIndex:i]]];
    }
}
@end
