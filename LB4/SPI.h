#define SPI_CLOCK_64 2
#define SPI_CLOCK_16 1
#define SPI_CLOCK_4  0
#define MODO_A       'A'		
#define MODO_B       'B'  
#define MODO_C		 'C'
#define MODO_D       'D'
#define SDI_MIT	     0
#define SDI_FIN      1  
void INICIO_SPI(char reloj,char modo, char smp);
void TX_SPI(char dato);
char RX_SPI(char dato);
