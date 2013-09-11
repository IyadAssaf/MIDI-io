MidiIO
======

MidiIO is a CoreMIDI wrapper for OSX. 
The project aims to make getting and sending MIDI events stupidly easy so people can get on with creating awesome things.

###Methods:
  
    MidiIO *midi = [[MidiIO alloc] init];
    
    //Send a note to a device:
    [midi sendMIDINoteToDevice:1 :127 :@"Launchpad"];
     
    //Send a control note to a device:
    [midi sendMIDIControlToDevice:1 :0 :@"Controls"];
      
      
###Callbacks:
      
      //Recieved a note
      -(void)recievedNote:(int)note :(int)velocity :(NSString *)device;
    
      //Recieved a control message
      -(void)recievedControl:(int)note :(int)velocity :(NSString *)device



