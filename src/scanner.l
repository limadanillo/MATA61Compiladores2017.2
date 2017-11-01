 /* Secao das declaracoes */


  /* Sera copiado no .c final */
%{
    #include <stdlib.h>
    #include <string.h>
   
    /* este include eh importante... */
    #include "tokens.h"
    void saidaArquivoAux( char * palavra , char *classe, int linha);
    char* stringbuffer;
	int column = 0;
int line = 1;
char error_buffer[256];
void count();
   
%}

%option noyywrap 


DIGIT   [0-9]+ 
ALPHA   [a-zA-Z]+ 
ALNUM   [0-9a-zA-Z]* 
IDENT   ([a-zA-Z])(_|[a-zA-Z]|[0-9]+)* 
NUMBER  [0-9]+
ERROR 	{DIGIT|_}+(_|{ALPHA})+{ALPHA}$
comentario (\-)(\-).*
branco (\t|"")*
saltarLinha \n



%%

\n { count(); }

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] { /* Multiline comment */ }

"//".* { /* one-line one */ }

let         {count(); printf("KEY \"%s\"%d \n",yytext, line );
            saidaArquivoAux( "KEY", yytext , line);}

def         {count(); printf("KEY \"%s\" %d \n",yytext, line);
            saidaArquivoAux("KEY",yytext , line);}

if          {count(); printf("KEY \"%s\" %d \n",yytext, line );
            saidaArquivoAux("KEY", yytext , line);}

else        {count(); printf("KEY \"%s\" %d \n",yytext, line);
            saidaArquivoAux("KEY", yytext , line);}

while       {count(); printf("KEY \"%s\"%d \n",yytext, line);
            saidaArquivoAux("KEY", yytext , line);}
          
return      {count(); printf("KEY \"%s\" %d \n",yytext, line);
            saidaArquivoAux("KEY", yytext , line);}

break       {count(); printf("KEY \"%s\" %d \n",yytext, line);
            saidaArquivoAux("KEY", yytext , line);}

continue    {count(); printf("KEY \"%s\" %d \n",yytext, line);
            saidaArquivoAux("KEY", yytext , line);}

\(          {count(); printf("SYM \"%s\" %d \n",yytext, line );
            saidaArquivoAux("SYM", yytext , line);}

\{          {count(); printf("SYM \"%s\" %d \n",yytext, line);
            saidaArquivoAux("SYM", yytext , line);}

"}"          { count(); printf("SYM \"%s\" %d \n",yytext, line);
            saidaArquivoAux("SYM", yytext , line);}

\)          {count(); printf("SYM \"%s\"%d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\,          {count(); printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\;          {count(); printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\=          {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\+          {count(); printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\-          {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\*          {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\/          {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\<          {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\>          {count();printf("SYM \"%s\"%d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\<=         {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\>=         {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\==         {count();printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\!=         {printf("SYM \"%s\" %d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\&&         {count();printf("SYM \"%s\"%d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}


"||"         {count(); printf("SYM \"%s\"%d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}

\!          {count(); printf("SYM \"%s\"%d \n",yytext , line);
            saidaArquivoAux("SYM", yytext , line);}
 
{comentario}    {}
{branco}        {}
{saltarLinha}   { }
{NUMBER}        {count();printf("DEC \"%s\"%d \n",yytext , line);
                saidaArquivoAux("DEC", yytext , line);}

{IDENT}         {count(); printf("ID \"%s\"%d \n",yytext , line);
                saidaArquivoAux("ID", yytext , line);}

.                                   {printf("ERROR \"%s\"%d \n",yytext , line);
            				saidaArquivoAux("ERROR", yytext , line); }

                
 /*-|\n*/


%%
 /* Secao dos  Procedimentos auxiliares  count(); */

 /* Para redefinir a entrada padrao do LEX. 
  * Redefinir a variavel 'yyin' para ler de um arquivo. Por exemplo:
     yyin = fopen("Meu_programa.c", "r");
  * ira mandar ler o programa a ser compilado pelo analisador lexical
  * em 'Meu_programa.c'.
  * O default eh ler da entrada standard (o teclado).
  */

FILE * saida;
int num_lines = 0;
extern FILE *yyin;
int main(int argc, char* argv[]) {

int token;

   saida = fopen(argv[2], "w+");
   if (argc != 3) {
      printf("uso: %s <input_file>. Try again!\n", argv[2]);
      exit(50);
   }
   yyin = fopen(argv[1], "r");
   if (!yyin) {
      printf("Uso: %s <input_file>. Could not find %s. Try again!\n", 
         argv[0], argv[1]);
      exit(55);
   }


  /* agora a entrada padrao eh o arquivo especificado como 1o argumento ao
   * executavel (argv[1]).
   * Soh chama o analisador lexical default fornecido pelo output do Flex:
   */

  while (token=yylex() ) { 
     
     /* neste laco, obtem-se "palavra por palavra" os tokens reconhecidos
      * pelo scanner fornecido pelo Lex. Poderia ser feita a analise
      * sintatica... Sera feito depois!*/

     printf("\n Meu analisador lexical reconheceu o token %d\n \n", token);

	
  }

  fclose(saida);
  return(0);
}

void saidaArquivoAux(  char *classe, char * palavra, int linha ){
    fprintf(saida, "%s  \"%s\" %d \n",  classe, palavra, linha); 
	if(classe =="ERROR"){
		fclose(saida);
  		return(0);
	}
}

void count() {
  int i;
  /* error_buffer could be implemented in the future */
  static char *eb = error_buffer;
  for (i = 0; yytext[i] != '\0'; i++) {
    if (yytext[i] == '\n') {
      column = 0;
      line++;
      eb = error_buffer;
    } else {
      *eb++ = yytext[i];
      column++;
      *eb = 0;
    }
  }
}






