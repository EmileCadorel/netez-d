module netez.common.socket;
import netez.datas.pack;
import std.socket;
import std.stdio;
import std.exception;
import net_addr = netez.common.address;
import netez.common.error;

class Socket {   

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

    void rawSend (T) (T data) {
	auto arr = (cast(ubyte*)&data)[0 .. T.sizeof];
	this.socket.send (arr);
    }
    
    void rawSend (void[] data) {
	this.socket.send (data);
    }

    T rawRecv (T) () {
	void [] data;
	data.length = T.sizeof;
	this.socket.receive (data);
	return (cast (T*) data [0 .. T.sizeof]) [0];
    }

    void[] rawRecv (ref ulong size) {
	void [] data;
	data.length = size;	
	size = this.socket.receive (data);
	return data;
    }
    
    void [] recv_all () {
	byte [] total;
	while (true) {
	    byte [] data;
	    data.length = 256;
	    auto length = this.socket.receive(data);
	    total ~= data;
	    if (length < 256) return total;
	}
    }

    void [] recv () {
	long [1] size;
	this.socket.receive(size);
	if (size [0] == -1) return [];
	void[] data;
	data.length = size[0];
	this.socket.receive (data);
	return data;
    }

    long recvId () {
	long [1] id;
	auto length = this.socket.receive(id);	
	if (length == 0) return -1;	
	return id[0];
    }
    
    Socket accept () {
	auto sock = this.socket.accept ();
	return new Socket (sock);
    }

    bool isAlive () {
	return this.socket.isAlive ();
    }
    
    net_addr.Address remoteAddress () {
	return new net_addr.Address (this.socket.remoteAddress ());
    }
    
    void shutdown () {       
	this.socket.shutdown (SocketShutdown.BOTH);
	this.socket.close ();
    }    
    
    ~this () {
    }
    
private:

    this (std.socket.Socket sock) {
	this.socket = sock;
    }
   
    std.socket.Socket socket;
    string addrstr;
    std.socket.Address addr;
    ushort port;
}
