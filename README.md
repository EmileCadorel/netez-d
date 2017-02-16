# netez-d

Netez is an open-source project, for creating simple TCP network applications, with the signals/slots system. (strongly inspired by [netez](https://launchpad.net/netez)).

## Goal

This project is designed to enable creating network applications for anybody with poor knowledge in network.  

## Example

- Protocol:
  The class EzProto, is shared by *Client* and *Server*. It's use to enable the communication

  ```D
      class Protocol : netez.EzProto {
        this (netez.EzSocket sock) {
          super (sock); 
          ping = new netez.EzMessage !(1) (this);
          pong = new netez.EzMessage !(2) (this);
        }
        netez.EzMessage!(1) ping;
        netez.EzMessage!(2) pong;
      }
  ```
  
- Session:
  A session is launched on each side of the communication (*server* and *client*), on the connection.
  On the *server* side, each session is a thread.

  ```D
  class Session : netez.EzClientSession!Protocol {
    this (netez.EzSocket sock) {
	    super (sock);
	    //When the client will receive PONG message, it will call PONG method.
	    this.proto.pong.connect (&this.pong); 
    }

    void pong () {
	    writeln ("~> PONG");
	    super.end_session ();
    }    

    override void on_begin () {
	    writefln ("Connexion etablie : %s:%s",
		    this.socket.remoteAddress.address,
		    this.socket.remoteAddress.port);
	    //Send PING message to the server.
	    this.proto.ping.send ();
    }

    override void on_end () {
	    writeln ("Deconnexion");
    }
}
  ```
  
- Client: 
  The *client* will create the connection with the *server* specified by an address and a port.

  ```D
    netez.EzClient!Session session = new netez.EzClient!Session ("localhost", 2000);
    //The following code will be executed, only if the client session has ended.
    ...
  ```

- Server
  The *server* will create a TCP server on a specific port, and instanciate a (Threaded) session each time a *client* want to connect.
  ```D
    //The session must inherit from EzServSession!(T : EzProto) ...
    netez.EzServer!Session session = new netez.EzServer!Session (2000);
  ```

