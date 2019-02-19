module netez.shell.signal;

import std.container;
import std.typecons;
import netez.shell.shell;
import std.string;

class ShellSignalBase {
    string id;
    string help;
    abstract bool recv (string);
}

class ShellSignal (string name, string help_, TArgs...) : ShellSignalBase {

    private SList!(void delegate(TArgs)) connections;   
    
    this (Shell shell_) {
	this.id = name;
	this.help = help_;
	shell_.register (this);
    }

    Tuple!TArgs parse (string line, ref bool success) {
	Tuple!TArgs ret;
	success = true;
	string [] splits = line.strip.split (" ");
	if (splits.length != ret.length) {
	    success = false;
	    return ret;
	}

	ulong i = 0;
	foreach (ref it ; ret) {
	    it = splits [i].to!(typeof (it));
	    i ++;
	}
	
	return ret;
    }

    void onRecv (void delegate (TArgs) fun) {
	this.connections.insertFront (fun);
    }
    
    void opCall (Tuple!TArgs datas) {
	foreach (it ; connections)
	    it (datas.expand);
    }

    override bool recv (string command) {
	bool success;
	auto vals = this.parse (command, success);
	if (!success) return false;
	this.opCall (vals);
	return true;
    }
        
}
