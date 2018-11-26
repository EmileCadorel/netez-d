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

class Session : netez.EzClientSession!Protocol {

    this (netez.EzSocket sock) {
	super (sock);
	this.proto.pong.connect (&this.pong);
    }

    void pong () {
	writeln ("~> PONG");
	super.end_session ();
    }    

    override void on_begin () {
	writefln ("Connexion etablie : %s:%s",
		  this.socket.remoteAddress.address,
		  this.socket.remoteAddress.port);
	this.proto.ping.send ();
    }

    override void on_end () {
	writeln ("Deconnexion");
    }
    
}

void main() {
    netez.EzClient!Session session = new netez.EzClient!Session ("localhost", 2000);
}
