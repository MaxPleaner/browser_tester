the general architecture is like so:

1. a web interface which uses two underlying rack apps:
  1. an api to create and edit files. it can also group files into components
  2. a ruby task runner, which runs the files (in selenium or otherwise)


