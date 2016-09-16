module EzAddressMod;

import std.socket;


/***
 Classe qui definie une adresse, tcp-ip
*/

class EzAddress {

    this (Address addr) {
	this.addr = addr;
    }

    string address () {
	return this.addr.toAddrString ();
    }

    string port () {
	return this.addr.toPortString ();
    }
        
    
private:

    Address addr;

}
