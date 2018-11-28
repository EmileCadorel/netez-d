module netez.net.proto;
import msg = netez.datas.message;
import sock = netez.common.socket;
import netez.common.error;

class Proto {

    this (sock.Socket sock) {	
	this.socket = sock;
    }
    
    void register (msg.MessageBase msg) {
	if (msg.id in this.regMsg) {
	    throw new EzMultiIdMessage (msg.id);
	}
	this.regMsg [msg.id] = msg;
    }
    
    msg.MessageBase [ulong] regMsg;

    sock.Socket socket;
    
}
