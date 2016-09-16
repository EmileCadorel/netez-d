module EzSocketMod;
import EzPackageMod;
import std.socket, std.stdio;
import std.exception;
import EzAddressMod;
import EzErrorMod;

class EzSocket {   

    class UnknownHost : Exception {
	this(string addr) {
	    super ("Adresse inconnu : " ~ addr);
	}
    }
   
    this (string addr, ushort port) {
	try {
	    auto addresses = getAddress (addr, port);
	    if (addresses.length == 0) {
		throw new UnknownHost (addr);
	    }
	    this.addrstr = addr;
	    this.addr = addresses[0];
	    this.port = port;
	    this.socket = new TcpSocket ();
	    this.socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
	} catch (Exception exp) {
	    throw new EzConnectionRefused (addr, port);
	}	
    }

    this (ushort port) {
	try {
	    this.port = port;
	    this.socket = new TcpSocket ();
	    this.socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
	} catch (Exception exp) {
	    throw new EzBindRefused (port);
	}
    }
    
    void connect () {
	try {
	    this.socket.connect (this.addr);
	} catch (Exception exp) {
	    throw new EzConnectionRefused (addrstr, port);
	}
    }

    void bind () {
	try {
	    this.socket.bind (new InternetAddress(this.port));
	} catch (Exception exp) {
	    throw new EzBindRefused (port);
	}
    }

    void listen () {
	this.socket.listen (1);
    }	  
	    
    void sendId (ulong id) {
	this.socket.send ([id]);
    }

    void send (void [] data) {
	this.socket.send ([data.length]);
	this.socket.send (data);
    }

    void [] recv () {
	ulong size[1];
	this.socket.receive(size);
	void[] data;
	data.length = size[0];
	this.socket.receive (data);
	return data;
    }

    long recvId () {
	long id[1];
	auto length = this.socket.receive(id);
	if (length == 0) return -1;
	return id[0];
    }
    
    EzSocket accept () {
	auto sock = this.socket.accept ();
	return new EzSocket (sock);
    }

    EzAddress remoteAddress () {
	return new EzAddress (this.socket.remoteAddress ());
    }
    
    void shutdown () {       
	this.socket.shutdown (SocketShutdown.BOTH);
	this.socket.close ();
    }    
    
    ~this () {
    }
    
private:

    this (Socket sock) {
	this.socket = sock;
    }
   
    Socket socket;
    string addrstr;
    Address addr;
    ushort port;
}
