module EzServerMod;
import sock = EzSocketMod;
import std.conv;
import EzErrorMod;

class EzServer(T) {

    this (ushort port) {
	init (port);
    }   

    this (string [] options) {
	if (options.length == 2) {
	    string port = options[1];
	    foreach (it; port) {
		if (it < '0'|| it > '9')
		    throw new EzOptionError (port);
	    }
	    init (to!ushort (port));
	} else throw new EzUsageError ("port");
    }
    
 private:

    void init (ushort port) {
	this.socket = new sock.EzSocket (port);
	this.socket.bind ();
	this.socket.listen ();
	run ();	
    }
    
    void run () {
	while (true) {
	    sock.EzSocket client = this.socket.accept ();
	    auto session = new T (client);
	    session.start ();
	}
    }
    
    sock.EzSocket socket;
}
