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
	void [] data = receiver.rawRecv (len * T.sizeof);
	elems = (cast (T*) (data.ptr))[0 .. len];
    }
}

void unpack (U, T : T[U])(sock.Socket receiver, ref T[U] elems) {
    auto len = receiver.rawRecv!ulong ();
    foreach (it ; 0 .. len) {
	T value; U key;
	unpack (receiver, key);
	unpack (receiver, value);
	elems [key] = value;
    }
}

void fromArray(T : T[U], U, TArgs...) (sock.Socket receiver, ref T[U] first, TArgs next) {
    unpack ! (U, T[U]) (receiver, first);
    fromArray ! TArgs (receiver, next);
}

void fromArray (T : T[], TArgs...) (sock.Socket receiver, ref T[] first, TArgs next) {
    unpack ! (T[]) (receiver, first);
    fromArray ! TArgs (receiver, next);
}

void fromArray(T, TArgs...) (sock.Socket receiver, ref T first, ref TArgs next) {
    unpack ! T (receiver, first);
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
    foreach (key, value ; elem) {
	enpack (sock, key);
	enpack (sock, value);
    }
}

void toSocket (T : T[U], U, TArgs...) (sock.Socket sock, T[U] first, TArgs next) {
    enpack ! (U, T[U]) (sock, first);    
    toSocket ! TArgs (sock, next);
}

void toSocket (T, TArgs...) (sock.Socket sock, T first, TArgs next) {
    enpack ! T (sock, first);
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
