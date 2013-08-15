What?
===

Vex is a combination of dashboard, external node classifier and hiera backend for puppet CM ecosystems.  It was written to address deficiencies in existing projects when it comes to dependency resolution beyond the class -> node link and follows a talk I gave at Back Bay LISA in June of 2013 on Infrastructure CI.

Why?
===

Servers don't live in isolation.  Services(from the userland perspective) can and do span multiple servers or even pools of servers.  Without tracking those links if we want to test our configuration changes we need to either make dangerous assumptions or build out everything.

How?
===

The core of Vex is a DSL-esque syntax that enables arbitrary definitions of relationships between various configurations.  It utilizes MongoDB to store configurations composed of arbitrary serialized data and the relationships between them.

Installation:
- Get a mongo instance up and running.  For testing/development this is a simple as installing the package(.deb and .rpm are both available) and then running a start on the init script.
- Get a basic ruby kit up.  Install rubygems and then do a gem install bundler.  Vex was built to work on 1.8.7 systems so as not to exclude RHEL/CentOS and older Debian distrubitions.
- Git clone or download this repository into a location.
- Go to where this was downloaded, run bundle install.
- Configure config/mongo.yml if you secured mongo.
- script/rails server, or configure passenger.

A complete installation guide with integration examples should be available at some point.

Caveats and Compromises
===

Vex is currently quite raw.

The default configuration types and relationships follow the slides in the doc directory.  A problem with this is that the level of nested relationships can require a logarithmic growth relationship for actual queries, so to optimize for read, the default set up caches relationships inside the model.  This sacrifices save performance for read.

Roadmap
===
A lot of extra functionality is planned.  Much of this will be found inside issues attached to this github repository.
