connectivity-tester
===========

Simple TCP client and server appplication for testing network connectivity

### What's Here?
* [client.cpp](README.md#usage)
* [server.cpp](README.md#usage)

Allows you to digest the output of db.currentOp into a JSON one liner. Great for doing quick analysis.

### Requirements
- GNU build tools

compilation
--------------
The following commands can be used to compile the client and server respectively
 g++ -w client.cpp -o client
 g++ -w server.cpp -o server

usage
--------------
server <port>
client <servers ip> <port>

Run the server, then the client. You will see messages detailing the establishment of a connection.
Once connected the client and server will start sending a short message back and forth between themselves.
The delay between messages being send will slowly increase over time in order to try and trigger a timeout or keep alive expiry.
This is a reference implementation and can be used to test for connectivity issues between two points.
