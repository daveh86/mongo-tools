var exclusions = [ "admin", "test", "local", "config"];
var tbd = [];
//Javascript Contains function
Array.prototype.contains = function(obj) {
    var i = this.length;
    while (i--) {
        if (this[i] === obj) {
            return true;
        }
    }
    return false;
}

var dbs = db.getMongo().getDBNames();
for (var i = 0; i < dbs.length; i++){
	var dbi = dbs[i];
	if (!exclusions.contains(dbi)) {
		tbd.push(dbi);
	}
}
print("I have reviewed and plan to delete the folloing list of databases " + tbd);
print("Cancel now if you wish to avoid removing any of the above. I will wait 10 seconds");
sleep(10000);
for (var i = 0; i < tbd.length; i++){
	var databse = db.getSisterDB(tbd[i]).dropDatabase();;
	print(tbd[i] + " dropped");
}