module EzClientSessionMod;

import sock = EzSocketMod;
import proto = EzProtoMod;

/**
 Classe de session de client
 Instanciee par le EzClient lorsqu'il se connecte a un serveur
*/
class EzClientSession (T : proto.EzProto) {

    this (sock.EzSocket socket) {
	this.socket = socket;
	this.proto = new T(socket);
    }

    abstract void on_begin ();
    abstract void on_end ();

    final void end_session () {
	this.end = true;
    }

    /**
     Methode appelee lors de la connexion
     */
    final void start () {
	on_begin ();
	while (!end) {
	    auto id = this.socket.recvId ();
	    if (id == -1) break;
	    auto elem = (id in this.proto.regMsg);
	    if (elem !is null)
		elem.recv ();
	}
	this.socket.shutdown();
	on_end ();
    }

private:
    

    bool end = false;
    
protected:
    
    sock.EzSocket socket;
    T proto;
    
}
