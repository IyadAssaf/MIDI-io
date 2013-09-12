MidiIO
======

MidiIO is a simple CoreMIDI wrapper for OSX. 
The project aims to make getting and sending MIDI events stupidly easy so people can get on with creating awesome things.

###Methods:
  
    MidiIO *midi = [[MidiIO alloc] init];
    
    //Send a note to a device:
    [midi sendMIDINoteToDevice:1 :127 :@"Launchpad"];
     
    //Send a control note to a device:
    [midi sendMIDIControlToDevice:1 :0 :@"Controls"];
    
    //Send a sysex command to a device:
    [midi sendSysexToDevice:@"Controls" :@"F0 00 01 61 04 06 F7"];
      
      
###Callbacks:
      
      //Recieved a note
      -(void)recievedNote:(int)note :(int)velocity :(NSString *)device;
    
      //Recieved a control message
      -(void)recievedControl:(int)note :(int)velocity :(NSString *)device



###This project is open for contribution, feel free to contribute to make using CoreMIDI easy to use on OSX!
