//
//  MidiIO.h
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <AudioUnit/AudioUnit.h>

@interface MidiIO : NSObject

-(id)init;

/* MIDI Input */

-(void)reInitializeMIDIInput;
-(NSArray *)inputDevices;

-(void)addInputDevice:(NSString *)device;
-(void)removeInputDevice:(NSString *)device;

-(void)disposeInputDevices;

/* MIDI Output */
-(NSArray *)outputDevices;

-(void)addOutputDevice:(NSString *)device;
-(void)removeOutputDevice:(NSString *)device;

-(void)sendNote:(int)pitch :(int)vel;






-(void)sendMIDIControl:(int)note :(int)velocity;

-(void)clear;

-(void)sendMIDINoteToDevice:(int)note :(int)velocity :(NSString *)device;
-(void)sendMIDIControlToDevice:(int)note :(int)velocity :(NSString *)device;

-(void)disposeOutputDevices;

@end
