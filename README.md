What?
===

Vex is a combination of dashboard, external node classifier and hiera backend for the puppet CM ecosystem.  It was written to address deficiencies in existing projects when it comes to dependency resolution beyond the class -> node link and was written following a talk I gave at Back Bay LISA in June of 2013 on Infrastructure CI.

It also serves a more conventional UX into configuration data, at least compared to YAML.

Why?
===

Much work has been done recently on testing module code and individual nodes, but servers don't live in isolation.  Services(from the userland perspective) can and do span multiple servers or even pools of servers.  Without tracking those links if we want to test our configuration changes we need to either make dangerous assumptions or build out everything.

The reason why we want to do this is to prevent configuration or module changes that may test clean in isolation but will break existing services.  This is increasingly the largest cause of a service outage or failure.

Additionally, while you can accomplish a similar effect by having our "services" be classes which get realized in context in different ways, there:
- really isn't a good way to do this cleanly.  You can not(or at least could not) reliably modify classes on the basis of what classes are in the entire catalog because of the way the catalog compilation works.  So you are forced to define everything as a virtual resource and set up a realization in each actual class in order to get the order right.
- even if that ever gets fixed, you're forced to overly burden your puppetmaster with a ton of classes which ultimately represent incremental configuration data.
- an utter lack of array support due to puppet's declarative nature makes quite a few things very hard to do in pure puppet code even with augeas.  IE: DNS.  Hiera addresses this but existing dashboards aren't(or weren't) also hiera backends.
- there is no good way to do pool deduplication, so if you have a hundred servers all identically configured you will either be building out all of them, or having to do a lot of crunching inside your Rakefile for the build task.

How?
===

The core of Vex is a DSL-esque(I say esque because it's working by adding mixins to existing model syntax) syntax that enables arbitrary definitions of relationships between various configurations.  It utilizes MongoDB to store configurations and the relationships between them.

Installation:
- Get a mongo instance up and running.  For testing/development this is a simple as installing the package(.deb and .rpm are both available) and then running a start on the init script.
- Get a basic ruby kit up.  Install rubygems and then do a gem install bundler.  Vex was built to work on 1.8.7 systems so as not to exclude RHEL/CentOS and older Debian distros.
- Git clone or download this repository somewhere.
- Go to where this was downloaded, run bundle install.
- Configure config/mongo.yml if you secured mongo.
- Run rake db:mongo:index or script/vex.rb -n to set up the indexes
- script/rails server, or configure passenger.

A complete installation guide with integration examples should be available at some point.

License?
===

MIT for now.  Build on it.  Sell it.  Do whatever.

Trollop, which is used for the rake wrapper script, is licensed under the same terms as ruby itself(BSDL).

Caveats and Compromises
===

Vex is currently quite raw.

The default configuration types and relationships follow the slides in the doc directory.  A problem with this is that the level of nested relationships can trigger an enormous amount of queries to get the live state of everything, so to optimize for read, the application as it stands caches relationships inside the model.  This sacrifices save performance for read - but faking this so the UX is acceptable on this is at least doable.

Roadmap
===
A lot of extra functionality is planned.  Much of this will be found inside issues attached to this github repository.

At some point the relationships will be configured and the classes will be loaded dynamically at run time, with an option to store the relationship configurations in the database for clustered/distributed builds.  For now we're being a bit more conventional.

Project Status
===
Currently on hold as I refactor modules and get good and intimate with puppetDB.


Questions, Comments, Requests?
===

Feel free to open an issue or contact me directly.
