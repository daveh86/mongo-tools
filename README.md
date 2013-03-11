mongo-tools
===========

Tools for working with MongoDB outputs

### What's Here?
* [currentOp-digest](README.md#currentop-digest)

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
