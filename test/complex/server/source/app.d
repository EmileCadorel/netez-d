import std.stdio, std.format, std.conv;
import netez = netez._;

struct InnerStruct {
    @("pack") int a;
    @("pack") int b;
    int [] data;
}

class MyDataToSend {

    private string _data;
    private @("pack") InnerStruct _inner;

    this () {}
    
    this (string value, InnerStruct inner) {
	this._data = value;
	this._inner = inner;
    }

    override string toString () {
	return format ("%s : %s", this._data, this._inner.to!string);
    }
    
}

class Protocol : netez.Proto {

    this (netez.Socket sock) {
	super (sock);
	ping = new netez.Message !(1, MyDataToSend) (this);
    }
    
    netez.Message!(1, MyDataToSend) ping;
}

class Session : netez.ServSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
    }

    override void onBegin (netez.Address client) {
	this.proto.ping (new MyDataToSend ("Hello there !!", InnerStruct (1, 897, [2, 3, 4])));
    }

 private:

    netez.Address client;
    
}

void main (string [] args) {
    netez.Server!Session session = new netez.Server!Session (args);
}
