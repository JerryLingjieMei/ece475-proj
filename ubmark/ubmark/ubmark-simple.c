//========================================================================
// ubmark-vvadd
//========================================================================

#include "ubmark.h"
#include "ubmark-simple.dat"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{

    int size = 1;
    int dest[size];

    dest[0] = 0;

    int temp = 0;

    test_stats_on( temp );
    *dest = 0;
    test_stats_off( temp );
    test_pass( temp );
    return 0;
}

