g++ -shared -static Client.cpp -lws2_32 -o Client.dll
strip Client.dll