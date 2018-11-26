module netez.net.proto;
import msg = netez.datas.message;
import sock = netez.common.socket;

class Proto {

    this (sock.Socket sock) {	
	this.socket = sock;
    }
    
    void register (msg.MessageBase msg) {
	this.regMsg [msg.id] = msg;
    }
    
    msg.MessageBase [ulong] regMsg;

    sock.Socket socket;
    
}
