module netez.common.address;

import socket = std.socket;

/***
 * Classe qui definie une adresse, tcp-ip
*/

class Address {

    this (socket.Address addr) {
	this.addr = addr;
    }

    string address () {
	return this.addr.toAddrString ();
    }

    string port () {
	return this.addr.toPortString ();
    }
        
private:

    socket.Address addr;

}
