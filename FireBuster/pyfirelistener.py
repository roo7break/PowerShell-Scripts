#!/usr/bin/python
#
# pyfirelistener.py
# Version 1.0
# Python version of FireListener for a PowerShell-less environment
#
# @roo7break
# Special thanks to Tom Forbes (tomforb.es)
#
# Usage: 
# ./pyfirelistener.py 4000 4100
#
# <Press Enter to exit>

import sys
import socket
import threading
 
def handle_port(port_num):
    s = socket.socket()
    try:
        s.bind(("0.0.0.0", port_num))
    except socket.error:
        print "Could not bind to %s" % port_num
        return
    
    s.listen(0)
    while True:
        sock, addr = s.accept()
        print "Client %s connected through port %s" % (addr[0], port_num)
        sock.close()

if __name__ == "__main__":
    print "Binding to 0.0.0.0\nPress Enter to exit any time"

    for port in xrange(int(sys.argv[1]), int(sys.argv[2])+1):
        t = threading.Thread(target=handle_port, args=(int(port),))
        t.daemon = True
        t.start()
    
    raw_input()