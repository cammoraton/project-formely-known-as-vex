vex
===

Vex is a dependency resolution system and pseudo-DSL for same built on Rails. I started writing it following a talk I gave at a BBLisa meeting in July of 2013 about 
Infrastructure Continious Integration(slides in the doc dir) and functions as both a Puppet external node classifier and a hiera backend.  The goal is to be able to define relationships
between configuration data in order to determine what endpoint servers need to be built out via jenkins in vagrant and what delta change needs to be tested.

Licensed under the MIT License for now, check the LICENSE file.

Installation:
- It's a rails app.  Edit mongo.yml, fire up the mongo instance you set up there.  Run bundle install.  Point passenger at it or run script/rails server.
- Oh and run rake db:mongo:index in the root directory to set up the indexes.

Using mongo as all we're basically doing is adding relationships to serialized data, a document-based nosql database is perfect for this.  Should be able to easily scale it horizontally to ridiculous levels.

We're optimizing towards read performance.  If there's a way to make a trade-off that improves read but beats up saving, I'll be making that trade-off.
One big example of this is updating associations and dependency caches, rather than generating them dynamically.  This gets retrieval of the end object down to a
single query(microseconds on my laptop with a few thousand objects of test data) but makes saves take up into the seconds(since our caching needs refactored in the worst way).

Currently vex is very, very raw.

Core Functionality remaining:
- YAML import/export.
- Navigation suuuckkks. Right now you go to: /nodes, /roles, /services, /pools, or /classes and define objects.  There's an index for each but no launch page.
- You have to know triggers.json, triggered_by.json, index.json(IE: /nodes.json) and object.json(ie: /nodes/test.json) exist to actually do anything with it.

After basics are done, there's still an awful lot of work(see issues) to do on this.
- Views(Version control)/a paper trail needs set up.  Alternatively we need to tightly couple this with VCS, so it batch exports as part of the cache update task and then does a commit as the user.  This would mean exporting the metadata though.
- Maybe do both of those?
- Changesets.  Want to batch these somehow.
- Reporting.  We need to be able to recieve reports(and artifacts) from BOTH puppet and jenkins
- Puppet Facts.  These would be nice for the dashboards.  Being able to arbitrarily assign them(so this can act as a fact source) would be nice too.
- A metric ton of commenting and tests need re-re-done.
- Once we've done all of that we may as well do mcollective integration.
- Should package it and any dependencies for debian/rhel based systems.  This needs to be EASY to install.  That also means packaging things like elasticsearch if we go that route.
- Optimize, optimize, optimize.
- Need to do examples for jenkins.
- Need to do a hiera backend.
- Need to write agents for elasticsearch.
- Should probably write something to parse puppet modules into elastic search at some point.
- Need to write agents for jenkins interaction.
- Growl would be really nice for me, personally.
- A plugin system would be aces.
