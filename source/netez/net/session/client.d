module netez.net.session.client;

import std.concurrency;
import sock = netez.common.socket;
import proto = netez.net.proto;
import addr = netez.common.address;
import core.thread;

private class ClientSessionThread (T) : Thread {

    ClientSession!T session;
    
    this (ClientSession!T session) {
	super (&run);
	this.session = session;
    }

    void run () {
	this.session.start ();
    }
    
}

/**
 Classe de session de client
 Instanciee par le Client lorsqu'il se connecte a un serveur
*/
class ClientSession (T : proto.Proto) {

    this (sock.Socket socket) {
	this.socket = socket;
	this.proto = new T(socket);
    }

    void onBegin (){}
    void onEnd (){}

    final void endSession () {
	this.end = true;
    }

    /**
     Methode appelee lors de la connexion
     */
    final void start () {
	onBegin ();
	while (!end) {
	    auto id = this.socket.recvId ();
	    if (id == -1) break;
	    auto elem = (id in this.proto.regMsg);
	    if (elem !is null)
		elem.recv ();
	}
	this.socket.shutdown();
	onEnd ();
    }

    final void startAsync () {
	this._thread = new ClientSessionThread!T (this);
	this._thread.start ();
    }

    final addr.Address getAddress () {
	return this.socket.remoteAddress ();
    }
    
    void join () {
	this._thread.join ();
    }

    final void close () {
	this.socket.shutdown ();
    }
    
private:
    

    bool end = false;
    private Thread _thread;
    
protected:
    
    sock.Socket socket;
    T proto;
    
}
