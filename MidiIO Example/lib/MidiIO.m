//
//  MidiIO.m
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import "MidiIO.h"

@implementation MidiIO

MIDIClientRef           outClient;
MIDIPortRef             outputPort;
MIDIEndpointRef         midiOut;

void initMIDIOut()
{
    
    //Create the MIDI client and MIDI output port.
    MIDIClientCreate((CFStringRef)@"Midi client", NULL, NULL, &outClient);
    MIDIOutputPortCreate(outClient, (CFStringRef)@"Output port", &outputPort);
    
}

void midiNoteOut (int note, int velocity)
{
    //Set up the data to be sent
    const UInt8 noteOutData[] = {  0x90 , note , velocity};
    
    
    //Create a the packets that will be sent to the device.
    Byte packetBuffer[sizeof(MIDIPacketList)];
    MIDIPacketList *packetList = (MIDIPacketList *)packetBuffer;
    ByteCount size = sizeof(noteOutData);
    
    MIDIPacketListAdd(packetList,
                      sizeof(packetBuffer),
                      MIDIPacketListInit(packetList),
                      0,
                      size,
                      noteOutData);
    
    MIDIEndpointRef outputEndpoint = MIDIGetDestination(0);
    MIDISend(outputPort, outputEndpoint, packetList);
    
    
}

void dispose ()
{
    MIDIClientDispose(outClient);
    MIDIPortDispose(outputPort);
}



- (id)init
{
    self = [super init];
    if (self) {
        
        dispose();
        initMIDIOut();
        
        
        for(int i=0; i<127; i++)
        {
            midiNoteOut(i, 0);
            [NSThread sleepForTimeInterval:0.001];
        }
        
        midiNoteOut(2, 60);
        midiNoteOut(5, 63);
        
    }
    return self;
}


@end
