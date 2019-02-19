module netez.shell.key;

import std.stdio;
import std.utf, std.conv;
import core.sys.posix.termios;
import core.sys.posix.unistd;
import core.sys.posix.fcntl;
import core.sys.posix.sys.time;

enum Type {
    ARROW_UP,
    ARROW_DOWN,
    ARROW_LEFT,
    ARROW_RIGHT,
    CTRL_D,
    CTRL_L,
    ENTER,
    DEL,
    SUPPR,
    CHAR,
    NONE
}

struct Key {
    Type type;

    dchar content;

    bool isControl = false;
    
    string toString () {
	with (Type) {
	    switch (type) {
	    case ARROW_UP : return "up";
	    case ARROW_DOWN : return "down";
	    case ARROW_LEFT : return "left";
	    case ARROW_RIGHT : return "right";
	    case ENTER : return "enter";
	    case DEL : return "DEL";
	    case SUPPR : return "SUPPR";
	    case CHAR : return content.to!string ();
	    default : return "None";
	    }
	}
    }    
}


void set_mode(bool want_key) {
    static termios old, nw;
    if (!want_key) {
	tcsetattr(STDIN_FILENO, TCSANOW, &old);
	return;
    }
 
    tcgetattr(STDIN_FILENO, &old);
    nw = old;
    nw.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &nw);
}

Key get_special_key () {
    char [4] c;
    c [1] = cast (char) getchar ();
    c [2] = cast (char) getchar ();
    switch (cast (int) c[2]) {
    case 51 : {
	c [3] = cast (char) getchar ();
	if (cast (int) c [3] == 126)
	    return Key (Type.SUPPR, 0);
	else {
	    c [1] = cast (char) getchar ();
	    c [2] = cast (char) getchar ();
	    return Key (Type.SUPPR, 0, true);
	}
    }
    case 65 : return Key (Type.ARROW_UP, 0);
    case 66 : return Key (Type.ARROW_DOWN, 0);
    case 67 : return Key (Type.ARROW_RIGHT, 0);
    case 68 : return Key (Type.ARROW_LEFT, 0);
    case 49 : {
	c [3] = cast (char) getchar ();
	auto key = get_special_key ();
	key.isControl = true;
	return key;
    } 
    default : return Key (Type.NONE, 0);
    }    
}

Key get_key()
{
    timeval tv;
    fd_set fs;
    tv.tv_usec = tv.tv_sec = 0;
 
    FD_ZERO(&fs);
    FD_SET(STDIN_FILENO, &fs);
    select(STDIN_FILENO + 1, &fs, null, null, &tv);

    int index = 0;
    char [4] c;
    if (FD_ISSET(STDIN_FILENO, &fs)) {
	c [0] = cast (char) getchar ();
	if (cast (int) c [0] == 27) {
	    return get_special_key ();
	} else {
	    index = 1;
	    do {
		try {	    
		    validate (c [0 .. index]);
		    break;
		} catch (UTFException ex) {
		    c [index] = cast (char) getchar();
		    index ++;
		}	    
	    } while (FD_ISSET(STDIN_FILENO, &fs) && index < 4);

	    set_mode(0);	
	    size_t i;
	    auto ret = (cast (string) c[0 .. index]).decode (i);
	    if (ret == '\n') return Key (Type.ENTER, ret);
	    if (cast (int) ret == 127) return Key (Type.DEL, ret);
	    if (cast (int) ret == 8) return Key (Type.DEL, ret, true);
	    if (cast (int) ret == 4) return Key (Type.CTRL_D, ret, true);
	    if (cast (int) ret == 12) return Key (Type.CTRL_L, ret, true);
	    return Key (Type.CHAR, ret);
	}
    } return Key (Type.NONE, 0);
}
