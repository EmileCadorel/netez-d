module netez.streaming.stream;

import std.container, std.typecons;
import pack = netez.datas.pack;
import sock = netez.common.socket;
import netez.datas.message;
import proto = netez.net.proto;

class Stream {
    private sock.Socket _socket;

    private this (sock.Socket socket) {
	this._socket = socket;
    }
    
    void write (T) (T datas) {
	pack.Package pck = new pack.Package ();
	pck.send (this._socket, datas);
    }

    T read (T) () {
	pack.Package pck = new pack.Package ();
	T ret;
	pck.unpack (this._socket, ret);
	return ret;
    }

    void close () {
	this._socket.shutdown ();
    }
    
}


class StreamMessage (ulong ID, TArgs ...) : Message!(ID, TArgs) {

    this (proto.Proto proto_) {
	super (proto_);	
    }

    override void send (TArgs datas) {
	auto port = getPort ();
	socket.sendId (this.id);
	socket.sendId (port);
	pack.Package pck = new pack.Package ();
	pck.send (this.socket, datas);
	createServer (port);
    }
    
    override void recv () {
	ushort port = cast (ushort) socket.recvId ();	
	Tuple!(TArgs) ret;
	pack.Package pck = new pack.Package ();
	pck.unpack (this.socket, ret.expand);	
	Stream str = this.connectTo (port);
	foreach (it ; this._slots)
	    it (str, ret.expand);
    }
    
    void connect (void delegate(Stream, TArgs) fun) {
	this._slots.insertFront (fun);
    }

    Stream open () {
	if (this._streamSocket is null) return null;
	sock.Socket client = this._streamSocket.accept ();
	return new Stream (client);
    }
    
 private :
    
    SList!(void delegate(Stream, TArgs)) _slots;
    static ushort __lastPort__ = 4000;

    sock.Socket _streamSocket;
    
    ushort getPort () {
	__lastPort__ ++;
	return __lastPort__;
    }

    void createServer (ushort port) {
	this._streamSocket = new sock.Socket (port);
	this._streamSocket.bind ();
	this._streamSocket.listen ();
    }

    Stream connectTo (ushort port) {
	sock.Socket socket = new sock.Socket (this.socket.remoteAddress ().address, port);
	socket.connect ();
	return new Stream (socket);
    }
    
}
