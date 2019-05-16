local function xcopy(
  pattern,
  root,
  dirs_to_exclude,
  files_to_exclude,
  destdir
  )
  recursive_descent(pattern, root, dirs_to_exclude, files_to_exclude, destdir)
end
return xcopy
