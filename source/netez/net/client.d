module netez.net.client;
import netez.net.session.client;
import sock = netez.common.socket;
import netez.common.error;
import std.conv;

/**
 Classe permettant la creation d'un client
 Le template T doit etre heriter de la classe ClientSession
*/
class Client (T : ClientSession!P, P) {

    this(string addr, ushort port) {
	init (addr, port);
    }

    this (string [] options) {
	if (options.length == 3) {
	    string addr = options[1];
	    string port = options[2];
	    foreach (it; port) {
		if (it < '0'|| it > '9')
		    throw new EzOptionError (port);
	    }
	    init(addr, to!ushort (port));
	} else throw new EzUsageError("address port");
    }
    
private:

    void init (string addr, ushort port) {
	this.socket = new sock.Socket (addr, port);
	this.socket.connect ();
	this.session = new T (socket);
	this.session.start ();
    }
    
    sock.Socket socket;
    T session; 
    
}