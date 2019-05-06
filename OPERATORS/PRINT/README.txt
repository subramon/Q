As per discussion in the previous call, modified the print_csv to use format as below

Q.print_csv({T}, opt_args)

Here, 
opt_args is a table of 3 arguments { opfile, filter, print_order}

  opfile: where to print the columns
            -- "file_name" : will print to file
            -- ""     : will return a string
            -- nil    : will print to stdout

  print_order: order for column names
                  -- nil : takes the complete vec_list as it is
                  -- table of strings (column names)
  
So the print_csv call will look like

opt_args = {opfile = "/tmp/abc.csv", filter = b1_vec, print_order = {'x', 'y'}} 
Q.print_csv({T}, opt_args)

Note: As per earlier convention, opt_args is optional argument i.e opfile, filter & print_order are optional.

In case if print_order is not mentioned and T is not with integer indexed table then print_csv doesn't guarantee about order in which it prints the columns.

Will modify the print_csv usage in tests and then will have pull request.

Regards,
Krushna.
