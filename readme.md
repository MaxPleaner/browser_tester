This is a web interface that acts as a sort of 'hub' for Selenium control.

Basically you can define userscripts through the web interface. These can
be in ruby (i.e. calling Capybara / Selenium commands) or can be in Javascript 
(i.e. if using Selenium's `execute_script`.



Prerequisites:

- a computer that responds to Unix file commands and has a GUI 
- ruby 2.3 or newer
- chromedriver: see [here](https://christopher.su/2015/selenium-chromedriver-ubuntu/)
  for setup instructions

Installation:

- clone this repo
- run `bundle install`
- run `sh start.sh`
- go to `localhost:3000`

Usage:

- to verify that things are working, make a new "command" (named anything)
 with content: `visit 'http://yahoo.com'`. Then press the button to run the 
 command and observe the website being opened in a browser. 
- Commands can be grouped into modules and exported to libraries. 
The web interface contains some more instructions about this. 