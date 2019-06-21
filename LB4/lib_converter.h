#include <xc.h>
#include <math.h>
#include <stdio.h>



float subtemp,y_1,y_2;
long int x1,x2,x3,x4,ON_mas,ON_menos,OFF_mas,OFF_menos,num_1,num_2;
long int ONh_mas,ONh_menos,OFFh_mas,OFFh_menos;

void convertir_binario(long int num){
    int i=0;
    num_1 = 0;
    num_2 = 0;
    while(num != 0){
        if (i < 8) {
            if (num%2 == 1){
            num_1 = num_1 + pow(2,i);
            }
        
        }       
        else {
        
            if (num%2 == 1){
            num_2 = num_2 + pow(2,i-8);
            }
        
        
        
        }
        num = num/2;
        i++;
    }
    
     
}



void converter_temptoservo (int temp,int dtemp,int PRE){
    subtemp = temp + (dtemp/10);
    
    y_1 = -0.0425*(subtemp)+2.35;
    
    x1 =  65535 - ((48000000*y_1)/(4*PRE*1000));
    convertir_binario(x1);
     ON_menos = num_1;
     ON_mas = num_2;
    
    x2 =  65535 - ((48000000*(20-y_1))/(4*PRE*1000));
    convertir_binario(x2);
     OFF_menos = num_1;
     OFF_mas = num_2;

    
    
    

}

void converter_humtoservo (int hum, int PRE){

    y_2 = -0.02125*(hum)+2.5625;
    
    x3 = 65535 - (48000000*y_2)/(4*PRE*1000);
    convertir_binario(x3);
    ONh_menos = num_1;
    ONh_mas = num_2;
    x4 = 65535 - ((48000000*(20-y_2))/(4*PRE*1000));
     convertir_binario(x4);
    OFFh_menos = num_1;
    OFFh_mas = num_2;

    
    

}

