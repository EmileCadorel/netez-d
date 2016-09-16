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

class Session : netez.EzServSession!Protocol {

    this (netez.EzSocket sock) {
	super (sock);
    }

    void on_begin (netez.EzAddress client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
	this.proto.array.send ([1, 2, 3]);
	this.proto.map.send (["hi" : 0, "bye" : 1]);
	super.end_session ();
    }

    void on_end () {
	writeln ("client deconnecte ", client.address, client.port);
    }

 private:

    netez.EzAddress client;
    
}

void main (string [] args) {
    netez.EzServer!Session session = new netez.EzServer!Session (args);    
}
