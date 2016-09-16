module EzServSessionMod;
import core.thread;
import sock = EzSocketMod;
import proto = EzProtoMod;
import EzAddressMod;
import std.stdio;

class EzServSession(T) : Thread {

    this (sock.EzSocket socket) {
	super (&run);
	this.socket = socket;
	this.proto = new T(socket);
    }

    abstract void on_begin (EzAddress addr);
    abstract void on_end ();

    final void end_session () {
	this.end = true;
    }
    
private:

    sock.EzSocket socket;
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
    
    T proto;
    
}
