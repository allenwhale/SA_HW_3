ps axouser,stat,pid|tail -n+2|sort -k1,1 -k2,2 -k3,3|xargs|awk '{u="";s="";split($0,a);for(i=1;i<=NF;i+=3){p="n";if(u!=a[i]){u=a[i];if(i!=1){printf(")\n");}printf("%s\n",a[i]);p="y";}if(s!=a[i+1]){s=a[i+1];if(p=="n"){printf(")\n");}printf("\t%s( ",a[i+1]);}printf("%d ",a[i+2]);}printf(")\n");}'