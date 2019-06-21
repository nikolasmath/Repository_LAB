#define _115200 25
#define _57600 51
#define _38400 77
#define _19200 155
#define _9600 311
#define _4800 624

void Abrir_Serial(int velocidad);
void TX_MENSAJE_EUSART(const unsigned char *vector,unsigned char pos);
void TX_CHAR_EUSART(char num);
