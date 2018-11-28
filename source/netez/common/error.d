module netez.common.error;
import std.exception;
import std.conv;

class EzError : Exception {
    this (string msg) {
	super (msg);
    }
}

class EzUsageError : EzError {
    this (string info) {
	super ("usage " ~ info);
    }        
}

class EzOptionError : EzError {
    this (string option) {
	super ("Option inconnu " ~ option);	
    }    
}

class EzConnectionRefused : EzError {
    this (string addr, ushort port) {
	super ("connection refuse " ~ addr ~ ":" ~ to!string(port));
    }    
}

class EzBindRefused : EzError {
    this (ushort port) {
	super ("bind: permission non-accorde port:" ~ to!string (port));
    }    
}

class EzMultiIdMessage : EzError {
    this (ulong id) {
	super ("message id : " ~ id.to!string ~ " is used multiple times");
    }
}



