echo ""|awk '{srand();cnt=0;C=4;L=2;A=3;W=60;H=30;SS=W+5;dx[1]=1;dx[2]=1;dx[3]=1;dx[4]=-1;dx[5]=-1;dx[6]=-1;dx[7]=0;dx[8]=0;dy[1]=1;dy[2]=0;dy[3]=-1;dy[4]=1;dy[5]=0;dy[6]=-1;dy[7]=1;dy[8]=-1;for(i=1;i<=H;i++){for(j=1;j<=W;j++){if(rand()>0.8){b[i*SS+j]="x";}else{b[i*SS+j]=" ";}}}time=0;while(1==1){cnt++;for(i=1;i<=H;i++){for(j=1;j<=W;j++){c=0;for(k=1;k<=8;k++){tx=i+dx[k];ty=j+dy[k];if(b[tx*SS+ty]=="x"){c=c+1;}}if(b[i*SS+j]=="x"){if(c<=L||c>=C){bb[i*SS+j]=" ";}else{bb[i*SS+j]="x";}}else{if(c>=A){bb[i*SS+j]="x";}else{bb[i*SS+j]=" ";}}}}for(i=1;i<=H;i++){for(j=1;j<=W;j++){b[i*SS+j]=bb[i*SS+j];}}system("clear");for(i=1;i<=W;i++){printf("=");}printf("\n");for(i=1;i<=H;i++){for(j=1;j<=W;j++){printf("%c",b[i*SS+j]);}printf("\n");}for(i=1;i<=W;i++){printf("=");}printf("\n");printf("%d",cnt);system("sleep 0.01");}}'
