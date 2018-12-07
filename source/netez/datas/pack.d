module netez.datas.pack;
import std.socket;
import std.stdio;

import sock = netez.common.socket;

/**
 System permettant l'enpaquetage des informations a transmettre par message
 */

void unpack (T) (sock.Socket receiver, ref T elem) {    
    elem = receiver.rawRecv!T ();    
}

void unpack (T : string) (sock.Socket receiver, ref T elem) {
    auto len = receiver.rawRecv!ulong ();
    void [] data = receiver.rawRecv (len);
    elem = cast (string) (cast (char*) (data.ptr)) [0 .. len];
}

void unpack (T : T[]) (sock.Socket receiver, ref T [] elems) {
    auto len = receiver.rawRecv!ulong ();
    static if (is (T U : U[V], V)) {
	elems = new T [len];
	foreach (it ; 0 .. elems.length)
	    unpack ! (V, U[V]) (receiver, elems [it]);
    } else static if (is (T U : U[])) {
	elems = new T [len];
	foreach (it ; 0 .. elems.length)
	    unpack ! (U[]) (receiver, elems [it]);
    } else static if (is (T U : string)) {
	elems = new T [len];
	foreach (it ; 0 .. elems.length)
	    unpack ! (string) (receiver, elems [it]);   
    } else {
	auto size = len * T.sizeof;
	void [] data = receiver.rawRecv (size);
	elems = (cast (T*) (data.ptr))[0 .. len];
    }
}

void unpack (U, T : T[U])(sock.Socket receiver, ref T[U] elems) {
    auto len = receiver.rawRecv!ulong ();
    writeln ("Unpack : ", typeid (T[U]), " of len : ", len);
    foreach (it ; 0 .. len) {
	T value; U key;
	unpack (receiver, key);
	writeln ("\t - Unpack : ", typeid (T[U]), " Key : ", key);
	unpack (receiver, value);
	writeln ("\t - Unpack : ", typeid (T[U]), " value : ", value);
	elems [key] = value;
    }
}

void fromArray(T, TArgs...) (sock.Socket receiver, ref T first, ref TArgs next) {
    static if (is (T U : U [V], V)) {
	unpack ! (V, U[V]) (receiver, first);
    } else static if (is (T U : U [])) {
	unpack ! (U[]) (receiver, first);
    } else static if (is (T U : string)) {
	unpack ! (string) (receiver, first);
    } else {	
	unpack (receiver, first);
    }
    
    fromArray ! TArgs (receiver, next);
}

void fromArray () (sock.Socket receiver) {}

void enpack (T : string) (sock.Socket sender, T elem) {
    sender.rawSend (elem.length);
    sender.rawSend (cast (byte[]) elem);
}

void enpack (T) (sock.Socket sender, T elem) {
    sender.rawSend (elem);
}

void enpack (T : T[]) (sock.Socket sender, T [] elem) {
    import std.algorithm.mutation;
    sender.rawSend (elem.length);
    static if (is (T U : U[V], V)) {
	foreach (it ; 0 .. elem.length)
	    enpack ! (V, U[V]) (sender, elem [it]);
    } else static if (is (T U : U[])) {
	foreach (it ; 0 .. elem.length)
	    enpack ! (U[]) (sender, elem [it]);
    } else static if (is (T U : string)) {
	foreach (it ; 0 .. elem.length)
	    enpack ! (string) (sender, elem [it]);
    } else {
	sender.rawSend (cast (byte[]) elem);
    }
}

void enpack (U, T : T[U]) (sock.Socket sock, T [U] elem) {
    sock.rawSend (elem.length);
    writeln ("Enpack : ", typeid (T[U]), " of len : ", elem.length);
    foreach (key, value ; elem) {
	enpack (sock, key);
	writeln ("\t - Enpack : ", typeid (T[U]), " key : ", key);
	enpack (sock, value);
	writeln ("\t - Enpack : ", typeid (T[U]), " value : ", value);
    }
}

void toSocket (T, TArgs...) (sock.Socket sock, T first, TArgs next) {
    static if (is (T U : U [V], V)) {
	enpack ! (V, U[V]) (sock, first);
    } else static if (is (T U : U[])) {
	enpack! (U []) (sock, first);
    } else static if (is (T U : string)) {
	enpack ! (string) (sock, first);
    } else {
	enpack ! T (sock, first);
    }
    toSocket ! TArgs (sock, next);
}

void toSocket () (sock.Socket sock) {}

class Package {
    
    void send (TArgs...) (sock.Socket socket, TArgs elems) {
	toSocket ! TArgs (socket, elems);
    }
    
    void unpack (TArgs...) (sock.Socket socket, ref TArgs suite) {
	fromArray !TArgs (socket, suite);	
    }

private:

    void [] datas;
    
}
