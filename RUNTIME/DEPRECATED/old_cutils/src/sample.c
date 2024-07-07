#include <regex.h>        
#include <stdio.h>        
int 
main()
{
  regex_t regex;
  int reti;
  char msgbuf[100];

  /* Compile regular expression */
  //reti = regcomp(&regex, "^a[[:alnum:]]", 0);
  // reti = regcomp(&regex, "fo*.*", 0);
  reti = regcomp(&regex, ".*.pdf", 0);
  if (reti) {
    fprintf(stderr, "Could not compile regex\n");
    return -1;
  }

  /* Execute regular expression */
  // reti = regexec(&regex, "abc", 0, NULL, 0);
  reti = regexec(&regex, "foo.pdf", 0, NULL, 0);
  printf("reti = %d \n", reti);

  if (!reti) {
    puts("Match");
  }
  else if (reti == REG_NOMATCH) {
    puts("No match");
  }
  else {
    regerror(reti, &regex, msgbuf, sizeof(msgbuf));
    fprintf(stderr, "Regex match failed: %s\n", msgbuf);
    return -1;
  }

  /* Free memory allocated to the pattern buffer by regcomp() */
  regfree(&regex);
  return 0;
}
