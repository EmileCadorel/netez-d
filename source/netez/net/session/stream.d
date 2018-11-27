module netez.net.session.stream;
import core.thread;
import sock = netez.common.socket;
import proto = netez.net.proto;
import netez.streaming.stream;
import netez.common.address;
import std.stdio;


/**
 * Une session stream, est une session qui permet de communiquer avec
 * des applications externe qui ne connaissent pas le protocole
 * Elle ne communique que par l'intermediaire d'un stream et ne possède pas de protocole
 */
class StreamSession : Thread {
    
    this (sock.Socket socket) {
	super (&run);
	this.socket = socket;
    }

    abstract void onBegin (Stream stream);    
    void onEnd () {}

    final void endSession () {
	this.socket.shutdown ();
    }

private :

    bool _end = false;

    void run () {
	onBegin (new Stream (this.socket));
	onEnd ();
	endSession ();
    }

protected :

    sock.Socket socket;
    
}
