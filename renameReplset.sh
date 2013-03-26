#!/bin/bash
#BEFORE DOING ANYTHING YOU NEED TO BACKUP YOUR SERVERS
#Shutdown all hosts and remove the --replset prior to execution
for HOST in "localhost:50000" "localhost:50001" "localhost:50002"
do
OLDNAME="foo"
NEWNAME="bar"
INSERT=`mongo $HOST --eval "printjson(db.getSiblingDB('local').system.replset.findOne())" --quiet | sed "s/$OLDNAME/$NEWNAME/g"`
echo $INSERT
mongo $HOST --eval "db.getSiblingDB('local').system.replset.insert($INSERT)"
mongo $HOST --eval "db.getSiblingDB('local').system.replset.remove({_id: '$OLDNAME'})"
sleep 1;
mongo $HOST --eval "db.getSiblingDB('admin').shutdownServer()"
done

#Start all hosts back up with --replset $NEWNAME now
