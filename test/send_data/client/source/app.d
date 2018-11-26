import std.stdio;
import netez = netez._;


class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	msg = new netez.Message !(1, int[string][]) (this);
    }
    
    netez.Message!(1, int[string][]) msg;
}

class Session : netez.ClientSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.msg.connect (&this.array);
    }

    void array (int[string][] data) {
	writeln ("ARRAY ~> ", data);
    }

    void map (int[string] data) {
	writeln ("MAP ~> ", data);
    }    

    override void on_begin () {
	writefln ("Connexion etablie : %s:%s",
		  this.socket.remoteAddress.address,
		  this.socket.remoteAddress.port);
    }

    override void on_end () {
	writeln ("Deconnexion");
    }
    
}

void main (string [] args) {
    netez.Client!Session session = new netez.Client!Session (args);
}
