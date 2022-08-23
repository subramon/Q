int main(int argc, char **argv)
{
  int status;
  g_halt = 0; // means we are running
  pthread_t mem_thrd;
  status = pthread_create(&mem_thrd, NULL, &mem_fn, NULL);
  lua_State *L = lua_open();
  if (L == NULL) {
    l_message(argv[0], "cannot create state: not enough memory");
    return EXIT_FAILURE;
  }
  smain.argc = argc;
  smain.argv = argv;
  status = lua_cpcall(L, pmain, NULL);
  report(L, status);
  lua_close(L);
  g_halt = 1; // notification to threads to halt when possible
  pthread_join(bar_thrd, NULL); 
  return (status || smain.status > 0) ? EXIT_FAILURE : EXIT_SUCCESS;
}
