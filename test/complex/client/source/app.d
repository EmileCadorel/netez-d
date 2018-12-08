import std.stdio;
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

class Session : netez.ClientSession!Protocol {

    this (netez.Socket sock) {
	super (sock);
	this.proto.ping.connect (&this.ping);
    }

    void ping (MyDataToSend datas) {
	writeln (datas.toString ());
    }    
    
}

void main (string [] args) {
    netez.Client!Session session = new netez.Client!Session (args);
}
