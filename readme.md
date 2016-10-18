**about**

This is a web interface that acts as a sort of 'hub' for Selenium control.

Basically you can define userscripts through the web interface. These can
be in ruby (i.e. calling Capybara / Selenium commands) or can be in Javascript 
(i.e. if using Selenium's `execute_script`.

**Prerequisites**:

- a computer that responds to Unix file commands and has a GUI 
- ruby 2.3 or newer
- chromedriver: see [here](https://christopher.su/2015/selenium-chromedriver-ubuntu/)
  for setup instructions

**Installation**:

- clone this repo
- run `bundle install`
- run `sh start.sh`
- go to `localhost:9292`

**Usage**:

- to verify that things are working, make a new "command" (named anything)
 with content: `visit 'http://yahoo.com'`. Then press the button to run the 
 command and observe the website being opened in a browser. 
- Commands can be grouped into modules and exported to libraries. 
The web interface contains some more instructions about this. 
- If you're exporting modules, keep in mind that their destination folder ('/export') 
is ignored by git. Also ignored is the PStore database 

**Development**:

Here are some of the major gems & libraries this uses:

- sinatra
- pstore
- faye-websocket
- jquery + ui (drag / drop / sort)
- slim / coffeescript / sass
- capybara / selenium

There is no manual build step for slim / coffeescript / sass assets. 

However, faye-websockets only works when rack is run in production mode.
This is why `start.sh` uses `env RACK_ENV=production bundle exec rackup`.
A side-effect of this requirement is that the server needs to be restarted
after _every file change_. 

Here's a outline of some of the more important source code files.

- view code is split between [views/layout.slim](views/layout.slim)
  and [views/root.slim](views/root.slim)
  - layout.slim contains app-wide SASS code.
    It also defines some coffeescript helper methods and sets up websocket subscriptions.
    Everything else, though, is in root.slim.
- [config.ru](./config.ru) and [start.sh](./start.sh) are startup scripts.
  start.sh is higher-level
- [main_server.rb](./main_server.rb) is the entry point to the server.
  It mostly just requires files from [lib/](./lib/)
- inside [.gitignore](./gitignore) is `database.pstore`, `.env`,
  and the `exports/` folder. Exports and the database are ignored in case they
  contain private credentials. Using `.env` is optional.
- there is a seedling of a `rspec` test suite in [./spec/](./spec/). But it hasn't
  been given much love (it doesn't go a long way).
- as per usual in a Sinatra app, [public/](./public/) contains statically served
  assets (in this case, scripts like jquery). 
- the [lib/](./lib/) directory contains the main pieces that together make up the server.
  - [browser.rb](./lib/browser.rb) is the mechanism by which user-supplied
    commands are run on a selenium browser.
  - [capybara_driver.rb](./lib/capybara_driver.rb) has configuration options for the 
    capybara / selenium driver.
  - [core_utils.rb](./lib/core_utils.rb) contains some extensions to ruby core classes.
    - there isn't much here besides one important method: `delegate_to_driver`.
      See the file's comments for explanation. 
  - [driver_helpers.rb](./lib/driver_helpers.rb)
    - custom methods that are available to user-defined commands.
    - an imporant one here is `module_require` - see the comments for info. 
  - [routes.rb](./lib/routes.rb) - Sinatra's HTTP routes.
  - [websockets.rb](./lib/websockets.rb) - Server-side websocket API. 
- Environment variables defined in `.env` will be loaded using the Dotenv gem.
  This is optional; the app doesn't depend on any environment variables.
  But they can be used to store private credentials required for Selenium commands. 

**Caveats**:

this is a completely insecure app - it encourages remote code execution.
It'd be cool if it supported deployment (using a client / server Selenium setup),
but I haven't tried that yet and I'm not sure when I'll have the time. 

Another caveat is that this uses `PStore` as a database which only supports
one transaction at a time. So only one person should be using this app at once. 