#!/usr/bin/python
from ctypes import *

# MemMap = windll.LoadLibrary(".\_MemMap.dll")
MemMap = cdll.LoadLibrary(".\_MemMap.dll")

# int svInit(string Realm);
SetMemString = MemMap.SetMemString
SetMemString.argtypes = [c_wchar_p, c_wchar_p]
SetMemString.restype = c_wchar_p

# string svVersion();
GetMemString = MemMap.GetMemString
GetMemString.argtypes = [c_wchar_p]
GetMemString.restype = c_wchar_p

print ("GetMemString", GetMemString("GBPUSD"))
