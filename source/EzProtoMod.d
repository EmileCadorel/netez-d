module EzProtoMod;
import msg = EzMessageMod;
import sock = EzSocketMod;

class EzProto {

    this (sock.EzSocket sock) {	
	this.socket = sock;
    }
    
    void register (msg.EzMessageBase msg) {
	this.regMsg [msg.id] = msg;
    }
    
    msg.EzMessageBase [ulong] regMsg;

    sock.EzSocket socket;
    
}
