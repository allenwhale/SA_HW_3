#if 0
""""
print `cat flag`
__END__
"""
import os
p=os.system
#endif
#include <stdlib.h>
#define p(x) int main(){system(x);}
p("cat flag");

