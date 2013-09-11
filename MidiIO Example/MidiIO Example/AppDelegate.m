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

    /* Optionally add input and output devices */
    /* Defaults to all devices */
    
//    [midi addInputDevice:@"Launchpad"];
//    [midi addInputDevice:@"Controls"];
//    [midi addInputDevice:@"PCR 1"];
//    [midi addInputDevice:@"PCR 2"];
//    [midi addInputDevice:@"PCR MIDI IN"];
    
//    [midi addOutputDevice:@"Controls"];
//    [midi addOutputDevice:@"Launchpad"];
    
    [midi initMidiInput];
    [midi initMidiOut];
    

    
    /* Sending note test */
    for(int i=0; i<32; i++)
    {
        for(int e=0; e<127; e++)
        {
            [midi sendMIDIControlToDevice:i :e :@"Controls"];
        }
    
    }
    [midi sendMIDINoteToDevice:1 :127 :@"Launchpad"];
    
    
    
    /* Sysex send commands */
    //    [midi sendSysexToDevice:@"Controls" :@"F0 00 01 61 04 1D 01 08 09 16 17 24 25 32 F7"];
    //    [midi sendSysexToDevice:@"Controls" :walkModeStr];
    //    [midi sendSysexToDevice:@"Controls" :@" F0 00 01 61 04 06 F7"]; //Factory reset
    //    [midi sendSysexToDevice:@"Controls" :@"F0 00 01 61 04 20 01 F7" ]; //Decouple encoders from their LED value
    [midi sendSysexToDevice:@"Controls" :@"F0 00 01 61 04 20 00 F7" ]; //Couple encoders to their LED value
    
    
    
    /* Walk mode */
    int one, two, three, four, five, six, seven, eight;
    
    one = 127;
    two = 127;
    three = 127;
    four = 127;
    five = 127;
    six = 127;
    seven = 127;
    eight = 127;
    
    NSString *walkModeStr = [NSString stringWithFormat:@"F0 00 01 61 04 1D %d %d %d %d %d %d %d %d", one, two, three, four, five, six, seven, eight];

    
    // 1F : Set LED Ring indicators
//    [midi sendSysexToDevice:@"Controls" :[self buildSysexCode:@"F0 00 01 61 04" :@"1F 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01" :@" F7"]];
    
    [midi sendSysexToDevice:@"Controls" :[self setLEDRingIndicators:127]];
    
}

-(NSString *)buildSysexCode:(NSString *)header :(NSString *)commandID :(NSString *)cmd
{
    return [NSString stringWithFormat:@"%@ %@ %@", header, commandID, cmd];
    
}

-(NSString *)setLEDRingIndicators:(int)velocity
{
    NSString *header = @"F0 00 01 61 04";
    NSString *footer = @"F7";
    
    NSString *encoders = [NSString stringWithFormat:@" %d 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01 08 01", velocity];
    
    return [NSString stringWithFormat:@"%@ %@ %@", header, encoders, footer];
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
    
    [midi sendMIDIControlToDevice:1 :velocity :@"Controls"];
    

    
}


@end
