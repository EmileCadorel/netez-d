import std.stdio;
import netez = netez;

class Protocol : netez.EzProto {

    this (netez.EzSocket sock) {
	super (sock);
	ping = new netez.EzMessage !(1) (this);
	pong = new netez.EzMessage !(2) (this);
    }
    
    netez.EzMessage!(1) ping;
    netez.EzMessage!(2) pong;
}

class Session : netez.EzServSession!Protocol {

    this (netez.EzSocket sock) {
	super (sock);
	this.proto.ping.connect (&this.ping);
    }

    void ping () {
	writeln ("PING <~ ", client.address);
	this.proto.pong.send ();
    }

    override void on_begin (netez.EzAddress client) {
	this.client = client;
	writefln ("Nouveau client : %s:%s", client.address, client.port);
    }

    void on_end () {
	writeln ("client deconnecte");
    }

 private:

    netez.EzAddress client;
    
}

void main() {
    netez.EzServer!Session session = new netez.EzServer!Session (2000);
}
