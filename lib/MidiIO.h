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


@protocol MidiIODelegate <NSObject>

-(void)recievedNote:(int)note :(int)velocity :(NSString *)device;
-(void)recievedControl:(int)note :(int)velocity :(NSString *)device;

@end


@interface MidiIO : NSObject <MidiIODelegate>
{
    id <MidiIODelegate> myDelegate;
}

@property (assign) id <MidiIODelegate> myDelegate;

-(id)init;

/* MIDI Input */

-(void)initMidiInput;
-(void)reInitializeMIDIInput;
-(NSArray *)inputDevices;

-(void)addInputDevice:(NSString *)device;
-(void)removeInputDevice:(NSString *)device;

-(void)disposeInputDevices;

/* MIDI Output */

-(void)initMidiOut;

-(NSArray *)outputDevices;

-(void)addOutputDevice:(NSString *)device;
-(void)removeOutputDevice:(NSString *)device;

-(void)sendNote:(int)pitch :(int)vel;



-(void)sendMIDIControl:(int)note :(int)velocity;

-(void)clear;

-(void)sendMIDINoteToDevice:(int)note :(int)velocity :(NSString *)device;
-(void)sendMIDIControlToDevice:(int)note :(int)velocity :(NSString *)device;

-(void)disposeOutputDevices;


//PASSBACK
-(void)noteWasRecieved:(int)note :(int)velocity;



@end

