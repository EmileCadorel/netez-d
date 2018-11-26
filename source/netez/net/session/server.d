module netez.net.session.server;
import core.thread;
import sock = netez.common.socket;
import proto = netez.net.proto;
import netez.common.address;
import std.stdio;

class ServSession(T) : Thread {

    this (sock.Socket socket) {
	super (&run);
	this.socket = socket;
	this.proto = new T(socket);
    }

    abstract void on_begin (Address addr);
    abstract void on_end ();

    final void end_session () {
	this.end = true;
    }
    
private:


    bool end = false;
    
    void run () {
	on_begin (this.socket.remoteAddress());
	while (!end) {
	    auto id = this.socket.recvId ();
	    if (id == -1) break;
	    auto elem = (id in this.proto.regMsg);
	    if (elem !is null)
		elem.recv ();	    
	}
	this.socket.shutdown ();
	on_end ();
    }    

protected:
    
    sock.Socket socket;    
    T proto;
    
}
