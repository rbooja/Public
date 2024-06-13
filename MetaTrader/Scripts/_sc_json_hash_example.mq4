
//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

#include <_hash.mqh>
#include <_json.mqh>

#property strict
#property show_inputs

void OnStart() {
     Hash *h = new Hash();

    // Store values
    h.hPutInt("low",0);
    h.hPutInt("high",1);

    // Get values
    int high = h.hGetInt("high");

    // Loop
    HashLoop *l ;
    for( l = new HashLoop(h) ; l.hasNext() ; l.next()) {

        string key = l.key();

        int j = l.valInt();

        Print(key," = ",j);

    }
    delete l;

    delete h;

}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+
