import std.stdio;
import netez = netez._;

class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	file = new netez.StreamMessage !(1, string) (this);
    }
    
    netez.StreamMessage!(1, string) file;
}

class Session : netez.ClientSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.file.connect (&this.file);
    }

    void file (netez.Stream stream, string filename) {
	writeln (filename);
	auto file = File (filename, "w");
	while (true) {
	    string data = stream.read!string ();
	    if (data == []) break;
	    file.rawWrite (data);
	}
    }
    
    
    override void onBegin () {
	writefln ("Connexion etablie : %s:%s",
		  this.socket.remoteAddress.address,
		  this.socket.remoteAddress.port);
    }

    override void onEnd () {
	writeln ("Deconnexion");
    }
    
}

void main (string [] args) {
    netez.Client!Session session = new netez.Client!Session (args);
}
