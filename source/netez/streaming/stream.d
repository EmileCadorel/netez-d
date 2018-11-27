module netez.streaming.stream;

import std.container, std.typecons;
import pack = netez.datas.pack;
import sock = netez.common.socket;
import netez.datas.message;
import proto = netez.net.proto;
import std.outbuffer;

class Stream {
    private sock.Socket _socket;

    this (sock.Socket socket) {
	this._socket = socket;
    }
    
    void rawWrite (byte[] datas) {
	this._socket.rawSend (datas);
    }

    void rawWrite (string datas) {
	this._socket.rawSend (cast (byte []) datas);
    }

    ubyte[] rawRead (ulong len) {
	void [] data = this._socket.rawRecv (len);
	return cast (ubyte[]) (cast (ubyte*) data.ptr) [0 .. len];
    }

    ubyte[] rawRead () {
	OutBuffer buf = new OutBuffer ();
	while (true) {
	    ulong len = 256;
	    void [] vdata = this._socket.rawRecv (len);
	    ubyte [] data = cast (ubyte[]) (cast (ubyte*) vdata.ptr) [0 .. len];
	    buf.write (data);
	    if (len != 256) break;
	}
	
	return buf.toBytes ();
    }

    string rawRead (T : string)  () {
	OutBuffer buf = new OutBuffer ();
	while (true) {
	    ulong len = 256;
	    void [] vdata = this._socket.rawRecv (len);
	    ubyte [] data = cast (ubyte[]) (cast (ubyte*) vdata.ptr) [0 .. len];
	    buf.write (data);
	    if (len != 256) break;
	}
	
	return buf.toString ();
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

    bool isAlive () {
	return this._socket.isAlive ();
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
    
    override void opCall (TArgs datas) {
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

    void onRecv (void delegate(Stream, TArgs) fun) {
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
