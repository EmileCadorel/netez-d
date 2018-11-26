import std.stdio;
import netez = netez._;

class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	msg = new netez.Message !(1, int[string][]) (this);
    }
    
    netez.Message!(1, int[string][]) msg;
}

class Session : netez.ServSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
    }

    override void on_begin (netez.Address client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
	this.proto.msg.send ([
	    ["hi" : 1, "by" : 2, "truc" : 3],
	    ["salut" : 12, "test" : 45]
	]);
	super.end_session ();
    }

    override void on_end () {
	writeln ("client deconnecte ", client.address, client.port);
    }

 private:

    netez.Address client;
    
}

void main (string [] args) {
    netez.Server!Session session = new netez.Server!Session (args);    
}
