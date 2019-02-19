module netez.shell.shell;

import netez.shell.signal;
import netez.shell.key;

import std.stdio;
import core.sys.posix.unistd;
import core.sys.posix.sys.time, std.container;
import std.string, std.typecons;


class Shell {
       
    private {
	ShellSignalBase [string] sigs;
	
	dchar[] [] history;

	dchar[] currentLine;
	
	dchar[] stored;
	
	ulong cursor = 0;
	
	ulong historyIndex;
	
	ulong _wrote;
    }
        
    this () {}

    void start (ref bool end) {
	display ();
	while (!end) {	    
	    set_mode (true);
	    auto c = get_key ();
	    if (c.type == Type.NONE) usleep (1000);
	    else {
		with (Type) {
		    switch (c.type) {
		    case ARROW_UP : moveUp (); break;
		    case ARROW_DOWN : moveDown (); break;
		    case ARROW_LEFT : cursorLeft (c.isControl); break;
		    case ARROW_RIGHT : cursorRight (c.isControl); break;
		    case ENTER : validateCommand (); break;
		    case DEL : deleteChar (c.isControl); break;
		    case SUPPR : supprChar (c.isControl); break;
		    case CTRL_D : ignoreCommand (); break;
		    case CTRL_L : clearScreen (); break;
		    case CHAR : addChar (c.content); break;
		    default : {}
		    }
		}
		clear ();
		display ();
	    }
	}
    }
    
    private void addChar (dchar content) {
	currentLine = currentLine [0 .. cursor] ~ [content] ~ currentLine [cursor .. $];
	cursor ++;
    }

    private void moveUp () {
	if (historyIndex >= history.length) {
	    stored = currentLine;
	}

	if (historyIndex != 0) historyIndex --;
	if (history.length > historyIndex) {
	    currentLine = history [historyIndex];
	    cursor = currentLine.length;
	}
    }

    private void moveDown () {
	historyIndex ++;
	if (historyIndex >= history.length) {
	    historyIndex = history.length;
	    currentLine = stored;
	} else currentLine = history [historyIndex];
	
	cursor = currentLine.length;
    }

    private void cursorLeft (bool isControl) {
	if (!isControl) {
	    if (cursor != 0) cursor --;
	} else {
	    auto max = cursor < currentLine.length ? cursor : currentLine.length;
	    auto index = currentLine [0 .. max].lastIndexOf (' ');
	    if (index == -1) cursor = 0;
	    else cursor = index;
	}
    }

    private void cursorRight (bool isControl) {
	if (cursor < currentLine.length) {
	    if (!isControl) {
		cursor ++;
	    } else {
		auto index = currentLine [cursor + 1 .. $].indexOf (' ');
		if (index == -1) cursor = currentLine.length;
		else cursor = (index + cursor + 1);
	    }
	}
    }
        
    private void validateCommand () {
	if (strip (currentLine) != "")
	    history ~= strip (currentLine);
	writeln ();
	callSig (format ("%s", currentLine));	
	
	currentLine = [];
	cursor = 0;
	historyIndex = history.length;
	
    }

    private void callSig (string command) {
	auto index = command.indexOf (' ');
	if (index == -1) index = command.length;
	auto fstWord = command [0 .. index];

	auto sig = fstWord in this.sigs;
	if (sig is null) {
	    writefln ("%s : command not found", fstWord);
	} else {
	    if (!(*sig).recv (command [index .. $]))
		writefln ("Error : %s", sig.help);
	}
    }
    
    private void ignoreCommand () {
	currentLine = [];
	cursor = 0;
	writeln ();
    }
    
    private void deleteChar (bool isControl) {
	if (cursor > 0) {
	    if (!isControl) {
		currentLine = currentLine [0 .. cursor - 1] ~ currentLine [cursor .. $];
		cursor --;
	    } else {
		auto index = currentLine [0 .. cursor].lastIndexOf (' ');
		if (index == -1) {
		    currentLine = currentLine [cursor .. $];
		    cursor = 0;
		} else {
		    currentLine = currentLine [0 .. index] ~ currentLine [cursor .. $];
		    cursor = index;
		}
	    }
	} else cursor = 0;	
    }

    private void supprChar (bool isControl) {
	if (cursor != currentLine.length) {
	    if (!isControl) {
		currentLine = currentLine [0 .. cursor] ~ currentLine [cursor + 1 .. $];
	    } else {
		auto index = currentLine [cursor + 1.. $].indexOf (' ');
		if (index == -1) {
		    currentLine = currentLine [0 .. cursor];
		    cursor = currentLine.length;
		} else {
		    currentLine = currentLine [0 .. cursor] ~ currentLine [cursor + index + 1 .. $];
		    cursor = (cursor + index + 1);
		}
	    }
	}
    }
    
    private void clearScreen () {
	import core.stdc.stdlib;
	system("clear");
    }

    private void clear () {
	foreach (it ; 0 .. this._wrote)
	    write ('\b');

	foreach (it ; 0 .. this._wrote)
	    write (' ');
	
	foreach (it ; 0 .. this._wrote)
	    write ('\b');
    }

    private void display () {
	string data;
	if (cursor < currentLine.length) {
	    data = format ("> %s\u001B[1;41m%c\u001B[0m%s", currentLine[0 .. cursor], currentLine [cursor], currentLine [cursor + 1 .. $]);
	} else {
	    data = format ("> %s\u001B[1;41m \u001B[0m", currentLine);
	}

	write (data);
	stdout.flush ();
	this._wrote = data.length;
    }

    void register (ShellSignalBase sig) {
	this.sigs [sig.id] = sig;
    }

    ShellSignalBase [string] getAllMessages () {
	return this.sigs;
    }
    
}
