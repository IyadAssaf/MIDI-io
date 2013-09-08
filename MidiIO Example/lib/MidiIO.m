//
//  MidiIO.m
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import "MidiIO.h"

@implementation MidiIO

#pragma mark Midi Output
/* OUTPUT */

//Output variables
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

void disposeOutput ()
{
    MIDIClientDispose(outClient);
    MIDIPortDispose(outputPort);
}






#pragma mark Midi Input


MIDIClientRef   inClient;
MIDIPortRef     inPort;
AudioUnit       instrumentUnit;


void setupMidiInput()
{
    MIDIClientCreate(CFSTR("SuperSimpleMIDIIn"), NotificationProc, instrumentUnit, &inClient);
	MIDIInputPortCreate(inClient, CFSTR("Input port"), MIDIRead, instrumentUnit, &inPort);
    
    MIDIEndpointRef source = MIDIGetSource(0);
    
    
    CFStringRef endpointName = NULL;
    MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
    char endpointNameC[255];
    CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
    
    NSString *input = @"Launchpad";
    
    NSLog(@"Getting input from %@", input);
    
    MIDIPortConnectSource(inPort, source, (void*)[input UTF8String]);
    
}

//CoreMIDIutilities
#pragma mark CoreMIDI utilities

void NotificationProc (const MIDINotification  *message, void *refCon) {
	NSLog(@"MIDI Notify, MessageID=%d,", message->messageID);
}


static void	MIDIRead(const MIDIPacketList *pktlist, void *refCon, void *srcConnRefCon) {
    
    //Reads the source/device's name which is allocated in the MidiSetupWithSource function.
    const char *source = srcConnRefCon;
    
    //Extracting the data from the MIDI packets receieved.
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	Byte note = packet->data[1] & 0x7F;
    Byte velocity = packet->data[2] & 0x7F;
    
    for (int i=0; i < pktlist->numPackets; i++) {
        
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        
		if ((midiCommand == 0x09) || //note on
			(midiCommand == 0x08)) { //note off
			
            MusicDeviceMIDIEvent(instrumentUnit, midiStatus, note, velocity, 0);
            
            NSLog(@"%s - NOTE : %d | %d", source, note, velocity);
            
            midiNoteOut(note, velocity);
            
            
		} else {
            
            NSLog(@"%s - CNTRL  : %d | %d", source, note, velocity);
            
        }
		
        //After we are done reading the data, move to the next packet.
        packet = MIDIPacketNext(packet);
	}
    
}


void disposeInput ()
{
    MIDIClientDispose(inClient);
    MIDIPortDispose(inPort);
}




#pragma mark Obj-C methods

- (id)init
{
    self = [super init];
    if (self) {

        //For midi in:
        
        disposeInput();
        disposeOutput();
        setupMidiInput();
        
        //For midi out:
        initMIDIOut();
        
        
//        for(int i=0; i<127; i++)
//        {
//            midiNoteOut(i, 0);
//            [NSThread sleepForTimeInterval:0.000001];
//        }
//        
//        for(int i=0; i<127; i++)
//        {
//            midiNoteOut(i, 1);
//            [NSThread sleepForTimeInterval:0.001];
//        }
//        
//        midiNoteOut(2, 60);
//        midiNoteOut(5, 63);
        
    }
    return self;
}


-(void)sendNoteOut:(int)note :(int)velocity
{
    midiNoteOut(note, velocity);
    
}

@end
