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

After basics are done, there's still an awful lot of work to do on this.
- I need to figure out how I want to do common things.  Like default roles which will include DNS/etc.  Monitoring.
- The layouts are ok, but not great.  It looks amateurish(which it is as my skills of a designer are meh)
- I'm still not entirely happy with the controllers or models, but I'll live.  I'm commited to this basic structure now.
- Updating caches needs to be done better, initially optimized, and potentially eventually split off into a delayed job or something(maybe in a local sqlite db?). Right now the hit from this is a bit extreme as we're overzealous in how we cascade and that causes an ENORMOUS performance hit on save that feels really bad on the ui side.
- That means locks.  We'll need to build a list of all records we may touch, lock them with a confirmed write as a unique identifier, then do a batch update.  I should call this method child_of_pthread_mutex_lock(pthread_mutex_t).
- Indexing and set up needs done - we don't want to beat up the db any more than we already do in order to do the arbitrary indexing/search we want on the configurations
- Creature comforts like dashboards and dependency visualizations.  D3 is really nice for this.  There's a sunburst visualization included right now that took all of 5 minutes to set up.
- Wrapper scripts need to be done.  Really a creature comfort but we should really follow CLI conventions if our target audience is admins.  Can not assume they know rake's little foibles.
- Quite a few rake tasks need built out (import/export being the BIG one)
- Accounts need to be set up - which means permissions
- Machine accounts (ip/cert combo) need set up
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
- Need to write agents for jenkins.
- Growl would be really nice for me, personally.
- A plugin system would be aces.  That'd be a pretty significant refactor though and a lot of metaprogramming since we'd need to set up relationships dynamically if you wanted to allow people to extend models.
