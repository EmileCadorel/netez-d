import std.stdio;
import netez = netez._;

class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	ping = new netez.Message !(1) (this);
	pong = new netez.Message !(2) (this);
    }
    
    netez.Message!(1) ping;
    netez.Message!(2) pong;
}

class Session : netez.ServSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.ping.connect (&this.ping);
    }

    void ping () {
	writeln ("PING <~ ", client.address);
	this.proto.pong.send ();
    }

    override void onBegin (netez.Address client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
    }

    override void onEnd () {
	writeln ("client deconnecte");
    }

 private:

    netez.Address client;
    
}

void main() {
    netez.Server!Session session = new netez.Server!Session (2000);
}
