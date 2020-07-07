Trello noodles
==============

This is (currently) a quick and dirty script to render all the links between
various trello cards as a graph that can be used to understand their structure.

How to run the code
-------------------

* `bundle install` to get the ruby dependencies
* Install graphviz
* Get a trello API key and token with access to the board
* `export TRELLO_KEY=...`
* `export TRELLO_TOKEN=...`
* Run `make`

How to deploy
-------------

If you've got a cloud foundry accout there's a manifest file so you can `cf
login` and `cf push`.

