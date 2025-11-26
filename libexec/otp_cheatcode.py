import pyotp
import sys

#(venv311) # python cantrips/libexec/otp_cheatcode.py NLPCGO7MMVT5XH4TR75G6XIA2BJLZJNB

print (pyotp.TOTP(sys.argv[1]).now())
