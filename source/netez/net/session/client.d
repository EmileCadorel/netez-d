module netez.net.session.client;

import sock = netez.common.socket;
import proto = netez.net.proto;

/**
 Classe de session de client
 Instanciee par le Client lorsqu'il se connecte a un serveur
*/
class ClientSession (T : proto.Proto) {

    this (sock.Socket socket) {
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
    
    sock.Socket socket;
    T proto;
    
}
