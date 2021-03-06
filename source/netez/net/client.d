module netez.net.client;
import netez.net.session.client;
import netez.net.session.shell;
import sock = netez.common.socket;
import netez.common.error;
import std.conv;

/**
 Classe permettant la creation d'un client
 Le template T doit etre heriter de la classe ClientSession
*/
class Client (T : ClientSession!P, P) {

    this(string addr, ushort port) {
	this._port = port;
	this._addr = addr;
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
    

protected:

    void init (string addr, ushort port) {
	this.socket = new sock.Socket (addr, port);
	this.socket.connect ();
	this.session = new T (socket);
	this.session.start ();
    }
    
    sock.Socket socket;
    T session; 
    string _addr;
    ushort _port;
}


/**
 Classe permettant la creation d'un client
 Le template T doit etre heriter de la classe ClientSession
*/
class ShellClient (T : ShellSession!(P, S), P, S) {

    this(string addr, ushort port) {
	this._port = port;
	this._addr = addr;
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
    

protected:

    void init (string addr, ushort port) {
	this.socket = new sock.Socket (addr, port);
	this.socket.connect ();
	this.session = new T (socket);
	this.session.start ();
    }
    
    sock.Socket socket;
    T session; 
    string _addr;
    ushort _port;
}

class AsyncClient (T : ClientSession!P, P) {
    
    this(string addr, ushort port) {
	this._addr = addr;
	this._port = port;
    }

    this (string [] options) {
	if (options.length == 3) {
	    string addr = options[1];
	    string port = options[2];
	    foreach (it; port) {
		if (it < '0'|| it > '9')
		    throw new EzOptionError (port);
	    }
	    this._addr = addr;
	    this._port = port.to!ushort;
	} else throw new EzUsageError("address port");
    }

    T openSync (TArgs...) (TArgs args) {
	auto socket = new sock.Socket (this._addr, this._port);
	socket.connect ();
	auto session = new T (socket, args);
	session.start ();
	return session;
    }
    
    T open (TArgs...) (TArgs args) {
	auto socket = new sock.Socket (this._addr, this._port);
	socket.connect ();
	auto session = new T (socket, args);
	session.startAsync ();
	return session;
    }
    
protected : 

    string _addr;
    ushort _port;
    
}
