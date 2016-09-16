import std.stdio;
import netez = netez;

class Protocol : netez.EzProto {

    this (netez.EzSocket sock) {
	super (sock);
	array = new netez.EzMessage !(1, int[]) (this);
	map = new netez.EzMessage !(2, int[string]) (this);
    }
    
    netez.EzMessage!(1, int[]) array;
    netez.EzMessage!(2, int [string]) map;
}

class Session : netez.EzClientSession!Protocol {

    this (netez.EzSocket sock) {
	super (sock);
	this.proto.array.connect (&this.array);
	this.proto.map.connect (&this.map);
    }

    void array (int[] data) {
	writeln ("ARRAY ~> ", data);
    }

    void map (int[string] data) {
	writeln ("MAP ~> ", data);
    }    

    void on_begin () {
	writefln ("Connexion etablie : %s:%s",
		  this.socket.remoteAddress.address,
		  this.socket.remoteAddress.port);
    }

    void on_end () {
	writeln ("Deconnexion");
    }
    
}

void main (string [] args) {
    netez.EzClient!Session session = new netez.EzClient!Session (args);
}
