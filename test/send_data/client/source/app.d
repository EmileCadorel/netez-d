import std.stdio;
import netez = netez._;


class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	msg = new netez.Message !(1, int, string, int[string]) (this);
    }
    
    netez.Message!(1, int, string, int[string]) msg;
}

class Session : netez.ClientSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.msg.connect (&this.array);
    }

    void array (int x, string y, int[string] data) {
	writeln ("STRING ~> ", x, " ", y);
	writeln ("ARRAY ~> ", data);
    }

    void map (int[string] data) {
	writeln ("MAP ~> ", data);
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
