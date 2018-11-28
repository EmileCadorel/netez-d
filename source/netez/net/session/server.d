module netez.net.session.server;
import core.thread;
import sock = netez.common.socket;
import proto = netez.net.proto;
import netez.streaming.stream;
import netez.common.address;
import std.stdio;

class ServSession(T) : Thread {

    this (sock.Socket socket) {
	super (&run);
	this.socket = socket;
	this.proto = new T(socket);
    }

    void onBegin (Address addr){}
    void onEnd (){}

    final void endSession () {
	this.end = true;
    }
    
private:


    bool end = false;
    
    void run () {
	onBegin (this.socket.remoteAddress());
	while (!end) {
	    auto id = this.socket.recvId ();
	    if (id == -1) break;
	    auto elem = (id in this.proto.regMsg);
	    if (elem !is null)
		elem.recv ();	    
	}
	this.socket.shutdown ();
	onEnd ();
    }    

protected:
    
    sock.Socket socket;    
    T proto;
    
}
