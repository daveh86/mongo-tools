function isInt(n) {
   return typeof n === 'number' && n % 1 == 0;
}
function isValidIndex(n) {
	if(isInt(n)){
		if (n == -1 || n == 1){ return true;}
	} else {
		if (n == "text" || n == "2dsphere" || n == "2d") { return true;}
	}
	return false;
}
function minVerCheck(v){
	need = v.split(".")
	ver = db.version().split(".");
	if(ver[0] < need[0]){ return false;}
	if(ver[1] < need[1]){ return false;} 
	if(ver[2] < need[2]){ return false;} 
	return true;
}
//Mongodb Upgrade Preflight script
doaggr = minVerCheck("2.2.0");
if(!doaggr){ print("--NOTICE-- You are running with " + db.version() + " which doesnt support aggregeation. Not running duplicate user check")}
var dbs = db.getMongo().getDBNames();
for (var i = 0; i < dbs.length; i++){
	print("Checking db " + dbs[i])
	if(doaggr){
		aggr = db.getSiblingDB(dbs[i]).system.users.aggregate([{ $group : { _id : "$user" , number : { $sum : 1 } } },{ $match : { number : { $gt : 1} } }]).result
		if(aggr != ""){
			print("Error, the following users are duplicated" + tojson(aggr));
		}
	}
	if(dbs[i] != "local"){
    	indexes = db.getSiblingDB(dbs[i]).system.indexes.find();
    	for (var x = 0; x < indexes.length(); x++){
      		index = indexes[x];
      		//print(index.key)
      		for(var key in index.key){
	      		if(!isValidIndex(index.key[key])){
	      			print("--WARNING-- " + tojsononeline(index) + " has a bad value value as part of key " + tojson(index.key) + " this index should be removed")
	      		}
	    	}
	  	}
	  	var cols = db.getSiblingDB(dbs[i]).getCollectionNames();
	  	for (var x = 0; x < cols.length; x++){
	  		if(!cols[x].startsWith("system.")){
	  	  		col = db.getSiblingDB(dbs[i]).getCollection(cols[x])
	      		if(col.isCapped()){
	        		if(db.getSiblingDB(dbs[i]).system.indexes.find({ns: dbs[i] + "." + cols[x], key : {_id :1 }}).count() == 0){
	          			print("--WARNING-- " + dbs[i] + "." + cols[x] + " is capped but has no index on _id");
	        		}
	      		}
	    	}
  	  	}
  	}	
}