module EzMessageMod;
import pack = EzPackageMod;
import sock = EzSocketMod;
import proto = EzProtoMod;
import std.stdio;
import std.container;
import std.typecons;

class EzMessageBase {
    ulong id ;
    abstract void recv ();
}

/**
 Message permettant le communication entre une session client et une session serveur
 */
class EzMessage (ulong ID, TArgs...) : EzMessageBase {
    
    this (proto.EzProto proto_) {
	this.socket = proto_.socket;
	this.id = ID;
	proto_.register (this);	
    }

    void send (TArgs datas) {
	socket.sendId (this.id);
	pack.EzPackage pck = new pack.EzPackage ();
	auto to_send = pck.enpack (datas);
	socket.send (to_send);
    }

    void connect (void delegate(TArgs) fun) {
	this.connections.insertFront (fun);
    }
    
    void recv () {
	auto data = socket.recv ();
	Tuple!TArgs ret;
	pack.EzPackage pck = new pack.EzPackage ();
	pck.unpack (data, ret.expand);
	foreach (it ; connections)
	    it (ret.expand);
    }
    
private:
       
    SList!(void delegate(TArgs)) connections;
    sock.EzSocket socket;
    
}
