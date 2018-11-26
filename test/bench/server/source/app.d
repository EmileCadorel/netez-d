import std.stdio;
import netez = netez._;

class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	file = new netez.StreamMessage !(1, string) (this);
    }
    
    netez.StreamMessage!(1, string) file;
}

class Session : netez.ServSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
    }

    override void on_begin (netez.Address client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
	this.proto.file.send ("file.out");

	auto file = new File ("../TheFallOfMan.txt", "r");
	char [255] reading;
	netez.Stream str = this.proto.file.open ();
	while (true) {
	    auto buf = file.rawRead (reading);	    
	    if (buf.length != 0) str.write (buf);
	    if (buf.length != 255) break;
	}
	str.close ();
	
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
