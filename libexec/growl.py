#!/usr/bin/python
import Growl
import sys 
f = Growl.GrowlNotifier ("flename",['is','maybe','not'])
f.register ()
ltit = sys.stdin.readline ()
ltxt = sys.stdin.readline ()

f.notify ("is", ltit, ltxt); 
