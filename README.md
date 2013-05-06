mongo-tools
===========

Tools for working with MongoDB outputs

### What's Here?
* [currentOp-digest](README.md#currentop-digest)
* [drop.js](README.md#drop.js)
* [preflight](README.md#preflight)
* [connectivity-tester](connectivity-tester/README.md)
* [renameReplset.sh](README.md#renameReplset.sh)

Allows you to digest the output of db.currentOp into a JSON one liner. Great for doing quick analysis.

### Requirements
 - Install the 'yajl-ruby' gem

currentOp-digest
---------------
As it's name suggests this is for digesting the output of Mongo's db.currentOp true into a JSON one liner.
Takes a single file as an argument and any number of the mix and match arguments listed below.
Will automatically remove any leading data before the first open curly brace, but will fail if there is anything after the final curly brace. 

Options are:
These operations will each ouput seperately in batch after processing. If none are specified all are included
* -s S ~ operations greater than S number of seconds running
* -y Y ~ operations greater than Y number of yields 
* -w W ~ operations holding write lock for more than W
* -r R ~ operations holding read lock for more than R
The following arguments can be added to help query out specific types of operations
* -a ~ active operations only
* -i ~ inactive operations only 
* --ops [insert,query,getmore,update,none] ~ pick-and-mix list of valid operations
* --opid X ~ operations that have the opid X
* --ns NS ~ operations performed on namespace NS
* --xns NS ~ operations not performed on namespace NS
* --nsNotNill ~ operations performed on a namespace which does not evaluate to ""
* --lim L ~ list only the top L operations for each of the initial batches

drop.js
---------------
Simple script to drop all databases excluding those listed in the exclusions array.
Will give you 10seconds to review listed names that will be dropped before executing.
Executed by running with mongo shell. I.E. mongo [URI] drop.js

preflight
---------------
JavaScripts designed to check for issues you will encounter when upgrading/downgrading

renameReplset.sh
---------------
Helper script to perform a rename of a replica set. Not suitable for a replSet that is a shard.
Process for usage of this script should be:
* Perform a backup
* Modify script with and set the host string, OLDNAME and NEWNAME values
* Shutdown all hosts and remove the --replSet argument and start them again to place nodes in standalone mode
* Execute script
* Start hosts as normal and confirm replica set name has changed
