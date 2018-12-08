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

class Session : netez.ClientSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.pong.connect (&this.pong);
    }

    void pong () {
	writeln ("~> PONG");
	super.endSession ();
    }    

    override void onBegin () {
	writefln ("Connexion etablie : %s:%s",
		  this.socket.remoteAddress.address,
		  this.socket.remoteAddress.port);
	this.proto.ping.send ();
    }

    override void onEnd () {
	writeln ("Deconnexion");
    }
    
}

void main() {
    netez.Client!Session session = new netez.Client!Session ("localhost", 2000);
}
