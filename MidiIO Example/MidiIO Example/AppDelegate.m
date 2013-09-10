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
    [midi setMyDelegate:self];
    
//    [midi addInputDevice:@"Launchpad"];
//    [midi addInputDevice:@"Controls"];
//    [midi addInputDevice:@"PCR 1"];
//    [midi addInputDevice:@"PCR 2"];
//    [midi addInputDevice:@"PCR MIDI IN"];
    
//    [midi addOutputDevice:@"Controls"];
//    [midi addOutputDevice:@"Launchpad"];
  
    
    [midi initMidiInput];
    [midi initMidiOut];

    
    [midi sendMIDIControlToDevice:1 :0 :@"Controls"];
    
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

    for(int i=0; i<127; i++)
    {
        [midi sendMIDINoteToDevice:i :67];
    }
    
    for(int i=0; i<127; i++)
    {
        [midi sendMIDINoteToDevice:i :42];
    }

}

- (IBAction)listOutputDevices:(id)sender {
    
    NSArray *outputDevices = [midi outputDevices];
    self.label.stringValue = @"";
    
    for(int i=0; i<outputDevices.count; i++)
    {        
        self.label.stringValue = [self.label.stringValue stringByAppendingString:[NSString stringWithFormat:@"\n %d: %@", i, [outputDevices objectAtIndex:i]]];
    }
    
    for(int i=0; i<127; i++)
    {
        [midi sendMIDINoteToDevice:i :0];
    }
}


/* MIDI input callbacks */

-(void)recievedNote:(int)note :(int)velocity :(NSString *)device
{
    NSLog(@"Recieved note: %d with velocity %d from device %@", note, velocity, device);
    
    self.monitor.stringValue = [NSString stringWithFormat:@"Source: %@, Note: %d, Velocity: %d",device, note, velocity];
    
    if(velocity != 0)
    {
        [midi sendMIDINoteToDevice:note :14];
    } else {
        [midi sendMIDINoteToDevice:note :121];
    }
   
}

-(void)recievedControl:(int)note :(int)velocity :(NSString *)device
{
    NSLog(@"Recieved control: %d with velocity %d from device %@", note, velocity, device);
    
    self.monitor.stringValue = [NSString stringWithFormat:@"Source: %@, Control: %d, Velocity: %d",device, note, velocity];
    
}


@end
