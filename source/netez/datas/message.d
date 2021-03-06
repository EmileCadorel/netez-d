module netez.datas.message;
import pack = netez.datas.pack;
import sock = netez.common.socket;
import proto = netez.net.proto;

import std.stdio;
import std.container;
import std.typecons;

class MessageBase {
    ulong id ;
    abstract void recv ();
}

/**
 Message permettant le communication entre une session client et une session serveur
 */
class Message (ulong ID, TArgs...) : MessageBase {
    
    this (proto.Proto proto_) {
	this.socket = proto_.socket;
	this.id = ID;
	proto_.register (this);	
    }

    void send (TArgs datas) {
	synchronized (this.socket) {
	    socket.sendId (ID);
	    pack.Package pck = new pack.Package ();
	    pck.send (this.socket, datas);
	}
    }
    
    void opCall (TArgs datas) {
	synchronized (this.socket) {
	    socket.sendId (ID);
	    pack.Package pck = new pack.Package ();
	    pck.send (this.socket, datas);
	}
    }    

    void connect (void delegate(TArgs) fun) {	
	this.connections.insertFront (fun);
    }

    void onRecv (void delegate (TArgs) fun) {
	this.connections.insertFront (fun);
    }
    
    override void recv () {
	Tuple!TArgs ret;
	pack.Package pck = new pack.Package ();

	synchronized (this.socket) {
	    pck.unpack (this.socket, ret.expand);
	}
	
	foreach (it ; connections)
	    it (ret.expand);
    }
    
protected:
       
    SList!(void delegate(TArgs)) connections;
    sock.Socket socket;
    
}
