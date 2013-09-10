//
//  MidiIO.m
//  MidiIO Example
//
//  Created by Iyad Assaf on 08/09/2013.
//  Copyright (c) 2013 Iyad Assaf. All rights reserved.
//

#import "MidiIO.h"

@implementation MidiIO


#pragma mark variables
/* VARIABLES */

//Input variables
MIDIClientRef   inClient;
MIDIPortRef     inPort;
AudioUnit       instrumentUnit;
NSMutableArray *inputDevices;


//Output variables
MIDIClientRef           outClient;
MIDIPortRef             outputPort;
MIDIEndpointRef         midiOut;
NSMutableArray          *outputDevices;


/* C Callback to Obj-C delegate */

// need to have a reference to the object, of course
static MidiIO *delegate = NULL;

// call at runtime with your actual delegate
void setCallbackDelegate ( MidiIO* del ) { delegate = del; }

void noteCallback (int note, int velocity, NSString *device)
{
    [delegate recievedNote:note :velocity :device];
}

void controlCallback(int note, int velocity, NSString *device)
{;
    [delegate recievedControl:note :velocity :device];
}


#pragma mark Midi Input

void setupMidiInput()
{
    MIDIClientCreate(CFSTR("MidiIOInput"), NotificationProc, instrumentUnit, &inClient);
	MIDIInputPortCreate(inClient, CFSTR("Input port"), MIDIRead, instrumentUnit, &inPort);
    
    
    if(inputDevices.count)
    {
        for(int i=0; i<inputDevices.count; i++)
        {
            MIDIEndpointRef source = MIDIGetSource((int)[listInputSources() indexOfObject:[inputDevices objectAtIndex:i]]);
            
            CFStringRef endpointName = NULL;
            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
            char endpointNameC[255];
            CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
            
            NSString *input = [inputDevices objectAtIndex:i];
            NSLog(@"Getting input from %@", input);
            
            const char *inputCC = MakeStringCopy([input UTF8String]);
            
            MIDIPortConnectSource(inPort, source, (void*)inputCC);
        }
        
    } else {
        
        NSLog(@"DEFAULT");
        
        //Default: If no input sources have been selected.
        MIDIEndpointRef source = MIDIGetSource(0);
        
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
        
        NSString *input = @"Launchpad";
        NSLog(@"Getting input from %@", input);
        
        const char *inputCC = MakeStringCopy([input UTF8String]);
        MIDIPortConnectSource(inPort, source, (void*)inputCC);
    }

}




/* Conversion of NSString to const char * */
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
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
			
            //Send callback to objective-C
            noteCallback(note, velocity, [NSString stringWithUTF8String:source]);
            
		} else {
        
            //Send callback to objective-C
            controlCallback(note, velocity, [NSString stringWithUTF8String:source]);
            
        }
		
        //After we are done reading the data, move to the next packet.
        packet = MIDIPacketNext(packet);
	}
    
}

NSArray *listInputSources ()
{
    NSMutableArray *sourceArray = [[NSMutableArray alloc] init];
    unsigned long sourceCount = MIDIGetNumberOfSources();
    
    for (int i=0; i<sourceCount; i++) {
        MIDIEndpointRef source = MIDIGetSource(i);
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
        
        NSString *NSEndpoint = [NSString stringWithUTF8String:endpointNameC];
        [sourceArray addObject: NSEndpoint];
    }
    return (NSArray *)sourceArray;
}


void disposeInput ()
{
    MIDIClientDispose(inClient);
    MIDIPortDispose(inPort);
}







#pragma mark Midi Output
/* OUTPUT */

void initMIDIOut()
{
    //Create the MIDI client and MIDI output port.
    MIDIClientCreate((CFStringRef)@"MidiIOOutput", NULL, NULL, &outClient);
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
    
    if(outputDevices.count)
    {
        //Send MIDI to all devices in the outputDevices array
        for(int i=0; i<outputDevices.count; i++)
        {
            MIDIEndpointRef outputEndpoint = MIDIGetDestination([listOutputSources() indexOfObject:[outputDevices objectAtIndex:i]]);
            MIDISend(outputPort, outputEndpoint, packetList);
        }
    } else {
        
        //Send to the default - 0
        MIDIEndpointRef outputEndpoint = MIDIGetDestination(0);
        MIDISend(outputPort, outputEndpoint, packetList);
        
    }
    
}



void midiDataToDevice (int note, int velocity, NSString *device, bool isNoteOut)
{
    int type;
    
    if(isNoteOut)
    {
        //Noteout data
        type = 0x90;
        
    } else {
        //Control data
        type = 0xB0;
    }

    const UInt8 outData[] = {  type , note , velocity};
    
    
    //Create a the packets that will be sent to the device.
    Byte packetBuffer[sizeof(MIDIPacketList)];
    MIDIPacketList *packetList = (MIDIPacketList *)packetBuffer;
    ByteCount size = sizeof(outData);
    
    MIDIPacketListAdd(packetList,
                      sizeof(packetBuffer),
                      MIDIPacketListInit(packetList),
                      0,
                      size,
                      outData);
    
    NSLog(@"index of %@: %lu", device, (unsigned long)[listOutputSources() indexOfObject:device]);
    
    MIDIEndpointRef outputEndpoint = MIDIGetDestination([listOutputSources() indexOfObject:device]);
    MIDISend(outputPort, outputEndpoint, packetList);
    
}


NSArray *listOutputSources ()
{
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    unsigned long outputCount = MIDIGetNumberOfDestinations();
    
    for (int i=0; i<outputCount; i++) {
        MIDIEndpointRef source = MIDIGetDestination(i);
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
//        NSLog(@"Output device %d - %s", i, endpointNameC);
        
        NSString *NSEndpoint = [NSString stringWithUTF8String:endpointNameC];
        [outputArray addObject: NSEndpoint];
    }
    return (NSArray *)outputArray;
}


void disposeOutput ()
{
    MIDIClientDispose(outClient);
    MIDIPortDispose(outputPort);
}





#pragma mark Obj-C methods

- (id)init
{
    self = [super init];
    if (self) {
        
        inputDevices = [[NSMutableArray alloc] init];
        outputDevices = [[NSMutableArray alloc] init];
        
    }
    return self;
}


#pragma mark Obj-C Input methods

-(void)initMidiInput
{
    disposeInput();
    setupMidiInput();
    
    setCallbackDelegate([self myDelegate]);
}



-(void)reInitializeMIDIInput
{
    disposeInput();
    setupMidiInput();
}


-(NSArray *)inputDevices
{
    return listInputSources();
}

-(void)addInputDevice:(NSString *)device
{
    NSLog(@"Added input device: %@", device);
    [inputDevices addObject:device];
}

-(void)removeInputDevice:(NSString *)device
{
    [inputDevices removeObject:device];
}


-(void)disposeInputDevices
{
    disposeInput();
}





#pragma mark Obj-C Output methods

-(void)initMidiOut
{
    disposeOutput();
    initMIDIOut();
}

-(NSArray *)outputDevices
{
    return listOutputSources();
}

-(void)addOutputDevice:(NSString *)device
{
    NSLog(@"Added output device: %@", device);
    [outputDevices addObject:device];
}

-(void)removeOutputDevice:(NSString *)device
{
    [outputDevices removeObject:device];
}


-(void)clear
{
    for(int i=0; i<127; i++)
    {
        midiNoteOut(i, 127);
    }
    
    for(int i=0; i<127; i++)
    {
        midiNoteOut(i, 4);
    }

}

-(void)sendMIDINoteToDevice:(int)pitch :(int)velocity
{
    midiNoteOut(pitch, velocity);
}

-(void)sendMIDINoteToDevice:(int)note :(int)velocity :(NSString *)device
{
    midiDataToDevice(note, velocity, device, 1);
}

-(void)sendMIDIControlToDevice:(int)note :(int)velocity :(NSString *)device
{
    midiDataToDevice(note, velocity, device, 0);
}


-(void)disposeOutputDevices
{
    disposeOutput();
}

@end
