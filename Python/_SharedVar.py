#!/usr/bin/python
from ctypes import *

SharedVar = windll.LoadLibrary("SharedVar-w32.dll")

### // Core Functions

# int svInit(string Realm);
svInit = SharedVar.svInit
svInit.argtypes = [c_char_p]
svInit.restype = c_int

# string svVersion();
svVersion = SharedVar.svVersion
svVersion.restype = c_char_p

# int GMTUnixTime();
GMTUnixTime = SharedVar.GMTUnixTime
GMTUnixTime.restype = c_int

# int LocalUnixTime();
LocalUnixTime = SharedVar.LocalUnixTime
LocalUnixTime.restype = c_int

### // hashing functions

# string svMD5(string Value);
svMD5 = SharedVar.svMD5
svMD5.argtypes = [c_char_p]
svMD5.restype = c_char_p

# int svCRC32(string Value);
svCRC32 = SharedVar.svCRC32
svCRC32.argtypes = [c_char_p]
svCRC32.restype = c_int

### // Server Management

# bool svServerRunning();
svServerRunning = SharedVar.svServerRunning
svServerRunning.restype = c_bool

# string svServerPath();
svServerPath = SharedVar.svServerPath
svServerPath.restype = c_char_p

# bool svServerStart();
svServerStart = SharedVar.svServerStart
svServerStart.restype = c_bool

### // Variable Get & Set

# bool svExists(int Handle, string Name);
svExists = SharedVar.svExists
svExists.argtypes = [c_int, c_char_p]
svExists.restype = c_bool

# bool svSetString(int Handle, string Name, string Value);
svSetString = SharedVar.svSetString
svSetString.argtypes = [c_int, c_char_p, c_char_p]
svSetString.restype = c_bool

# bool svSetValue(int Handle, string Name, double Value);
svSetValue = SharedVar.svSetValue
svSetValue.argtypes = [c_int, c_char_p, c_double]
svSetValue.restype = c_bool

# bool svSetBool(int Handle, string Name, bool Value);
svSetBool = SharedVar.svSetBool
svSetBool.argtypes = [c_int, c_char_p, c_bool]
svSetBool.restype = c_bool

# bool svIncValue(int Handle, string Name, double IncBy);
svIncValue = SharedVar.svIncValue
svIncValue.argtypes = [c_int, c_char_p, c_double]
svIncValue.restype = c_bool

# bool svGetBool(int Handle, string Name);
svGetBool = SharedVar.svGetBool
svGetBool.argtypes = [c_int, c_char_p]
svGetBool.restype = c_bool

# double svGetDouble(int Handle, string Name);
svGetDouble = SharedVar.svGetDouble
svGetDouble.argtypes = [c_int, c_char_p]
svGetDouble.restype = c_double

# int svGetInt(int Handle, string Name);
svGetInt = SharedVar.svGetInt
svGetInt.argtypes = [c_int, c_char_p]
svGetInt.restype = c_int

# string svGetString(int Handle,string Name);
svGetString = SharedVar.svGetString
svGetString.argtypes = [c_int, c_char_p]
svGetString.restype = c_char_p

# int svUpdated(int Handle, string Name);
svUpdated = SharedVar.svUpdated
svUpdated.argtypes = [c_int, c_char_p]
svUpdated.restype = c_int

# int svCreated(int Handle, string Name);
svCreated = SharedVar.svCreated
svCreated.argtypes = [c_int, c_char_p]
svCreated.restype = c_int

### // removing

# bool svRemoveAll(int Handle);
svRemoveAll = SharedVar.svRemoveAll
svRemoveAll.argtypes = [c_int]
svRemoveAll.restype = c_bool

# bool svRemovePrefix(int Handle, string Prefix);
svRemovePrefix = SharedVar.svRemovePrefix
svRemovePrefix.argtypes = [c_int, c_char_p]
svRemovePrefix.restype = c_bool

### // Enumeration Realm & Variables

# int svRealmCount();
svRealmCount = SharedVar.svRealmCount
svRealmCount.restype = c_int

# string svRealmName(int Index);
svRealmName = SharedVar.svRealmName
svRealmName.argtypes = [c_int]
svRealmName.restype = c_char_p

# int svVarCount(int Handle);
svVarCount = SharedVar.svVarCount
svVarCount.argtypes = [c_int]
svVarCount.restype = c_int

# string svVarName(int Handle, int Position);
svVarName = SharedVar.svVarName
svVarName.argtypes = [c_int, c_int]
svVarName.restype = c_char_p

#############################################

Link = -1
Link = svInit("ea1")
if 0 <= Link:
    print ("SharedVar Version : ", svVersion())
print ("GMTUnixTime()", GMTUnixTime())
print ("LocalUnixTime()", LocalUnixTime())
print ('svMD5("Demonstration")', svMD5("Demonstration"))
print ('svCRC32("Demonstration")', svCRC32("Demonstration"))
print ("svServerRunning()", svServerRunning())
print ("svServerPath()", svServerPath())
if svServerRunning() is False and svServerStart():
    if 0 <= svInit("table1"):
        print ("Success")
print ('svSetString(Link, "name", "john")', svSetString(Link, "name", "john"))
print ('svSetString(Link, "lastname", "doe")', svSetString(Link, "lastname", "doe"))
if svExists(Link, "name") is False:
    svSetString(Link, "name", "john")
print ('svSetValue(Link, "LastStart", LocalUnixTime())', svSetValue(Link, "LastStart", LocalUnixTime()))
print ('svSetValue(Link, "LastBid", 1.12045)', svSetValue(Link, "LastBid", 1.12045))

print ('svSetBool(Link, "Started", True)', svSetBool(Link, "Started", True))
print ('svIncValue(Link, "TotalPositions", 1)', svIncValue(Link, "TotalPositions", 1))
print ('svIncValue(Link, "TotalPositions", -1)', svIncValue(Link, "TotalPositions", -1))
print ('svIncValue(Link, "TotalLots", 0.30)', svIncValue(Link, "TotalLots", 0.30))
print ('svIncValue(Link, "TotalLots", -0.10)', svIncValue(Link, "TotalLots", -0.10))
name      = svGetString(Link, "name")
lastname  = svGetString(Link, "lastname")
Started   = svGetBool(Link, "Started")
LastStart = svGetInt(Link, "LastStart")
LastBid   = svGetDouble(Link, "LastBid")
print ('svUpdated(Link, "LastBid")', svUpdated(Link, "LastBid"))
print ('svCreated(Link, "LastBid")', svCreated(Link, "LastBid"))
print ("svRealmCount()", svRealmCount())
for i in range(svRealmCount()):
    print ("Realm[" + str(i) + "] = ", svRealmName(i))
for i in range(svVarCount(Link)):
    varname = svVarName(Link ,i)
    varvalue = svGetString(Link, varname)
    print ("Variable : " + varname + " = ", varvalue)

#############################################
"""
SharedVar Version :  1.2.0.310
GMTUnixTime() 1476087911
LocalUnixTime() 1476120311
svMD5("Demonstration") 59B8560745E92244C7BEED22D179D18E
svCRC32("Demonstration") -557312900
svServerRunning() True
svServerPath() D:\Program Files\SharedVar\SharedVar.exe
svSetString(Link, "name", "john") True
svSetString(Link, "lastname", "doe") True
svSetValue(Link, "LastStart", LocalUnixTime()) True
svSetValue(Link, "LastBid", 1.12045) True
svSetBool(Link, "Started", True) True
svIncValue(Link, "TotalPositions", 1) True
svIncValue(Link, "TotalPositions", -1) True
svIncValue(Link, "TotalLots", 0.30) True
svIncValue(Link, "TotalLots", -0.10) True
svUpdated(Link, "LastBid") 1476118029
svCreated(Link, "LastBid") 1476118029
svRealmCount() 1
Realm[0] =  ea1
Variable : TotalPositions =  0
Variable : LastBid =  1.12045
Variable : LastStart =  1476120311
Variable : Started =  1
Variable : TotalLots =  1.6
Variable : name =  john
Variable : lastname =  doe
"""