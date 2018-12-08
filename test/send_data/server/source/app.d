import std.stdio;
import netez = netez._;


class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	msg = new netez.Message !(1, int, string, int[string]) (this);
    }
    
    netez.Message!(1, int, string, int[string]) msg;
}

class Session : netez.ServSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
    }

    override void onBegin (netez.Address client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
	this.proto.msg.send (0, "test", ["core" : 2, "mem" : 12]);
	super.endSession ();
    }

    override void onEnd () {
	writeln ("client deconnecte ", client.address, client.port);
    }

 private:

    netez.Address client;
    
}

void main (string [] args) {
    netez.Server!Session session = new netez.Server!Session (args);    
}
