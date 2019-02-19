module netez.net.session.shell;

import shell = netez.shell.shell;
import std.concurrency;
import sock = netez.common.socket;
import proto = netez.net.proto;
import addr = netez.common.address;
import core.thread;

private class ShellSessionThread (T, X) : Thread {

    ShellSession!(T, X) session;
    
    this (ShellSession!(T, X) session) {
	super (&run);
	this.session = session;
    }

    void run () {
	this.session.runShell ();
    }
    
}

/**
 Classe de session de client
 Instanciee par le Shell lorsqu'il se connecte a un serveur
*/
class ShellSession (T : proto.Proto, S : shell.Shell) {

    this (sock.Socket socket) {
	this.socket = socket;
	this.proto = new T(socket);
	this.shell = new S ();
    }

    void onBegin (){}
    void onEnd (){}

    final void endSession () {
	this.end = true;
    }

    final void runShell () {	
	this.shell.start (this.end);
    }
    
    /**
     Methode appelee lors de la connexion
     */
    final void start () {	
	onBegin ();
	this._thread = new ShellSessionThread!(T, S) (this);
	this._thread.start ();
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
    S shell;
    
}
