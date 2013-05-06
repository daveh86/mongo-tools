#!/usr/bin/ruby

require 'yajl'
require 'optparse'

#Init the Arrays

readArray = Array.new()
writeArray = Array.new()
secsArray = Array.new()
yieldsArray = Array.new()
allArray = Array.new()

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: curropRun.rb [-r R|-w W| -s S] [-a|-f] filename"
  opts.on("-w W", Integer, "Find write queries over W microseconds") do |v|
    options[:write] = v.to_i
  end
  opts.on("-r R", Integer, "Find read queries over R microseconds locked") do |v|
    options[:read] = v.to_i
  end
  opts.on("-s S", Integer, "Find queries over S seconds long") do |v|
    options[:seconds] = v.to_i
  end
    opts.on("-y Y", Integer, "Find Queries yielded more than Y times") do |v|
    options[:yield] = v
  end
  opts.on("-a", "Find active queries") do |v|
    options[:active] = true
  end
  opts.on("-i", "Find in-active queries") do |v|
    options[:active] = false
  end
  opts.on("--ops insert,query,getmore,update,none", Array, "Which operations?") do |v|
    options[:ops] = v
  end
  opts.on("--opid opid", Integer, "Which operations?") do |v|
    options[:opid] = v
  end
  opts.on("--ns ns", String, "Which Namespace?") do |v|
    options[:ns] = v
  end
  opts.on("--xns ns", String, "Not which Namespace?") do |v|
    options[:xns] = v
  end
    opts.on("--nsNotNill", "Not empty Namespaces?") do |v|
    options[:nnns] = true
  end
  opts.on("--lim lim", Integer, "Display the top how many?") do |v|
    options[:limit] = v
  end
  opts.on("--json", "Output in JSON for import to a MongoDB instance") do |v|
    options[:json] = v
  end
end.parse!

if ARGV[0] == NIL
  puts "Usage: curropRun.rb [-r R|-w W| -s S] filename"
  exit(1)
end
#p options
#p ARGV


def digestFile(filename)
	fh = File.open(filename)
	array =  String.new
	preparse = true
	fh.each_line do |line|
		if preparse
			if line =~ /\{/
				preparse = false
				array << line
			end
		else
			#Sub numberlongs
			if line.include? "NumberLong\("
				line.slice!(/NumberLong\(/)
				line.slice!(/\)/)
			end

			#ObjectId("4ef4af0963389003f300c2e7"),
			if line.include? "ObjectId"
				line = line.gsub("ObjectId\(\"", "\"ObjectId\(")
				line = line.gsub("\"\)", "\)\"")
			end

			#Timestamp(10000, 27),
			if line.include? ": Timestamp\("
				line = line.gsub("Timestamp\(", "\"Timestamp\(")
				line = line.gsub("\)", "\)\"")
			end
			#ISODate("2012-01-26T00:00:00Z")
			if line.include? ": ISODate\(\""
				line = line.gsub("ISODate\(\"", "\"ISODate\(")
				line = line.gsub("\"\)", "\)\"")
			end
      #BinData
      if line.include? ": BinData\("
        line = line.gsub("BinData\(", "\"BinData\(")
        line = line.gsub("\"\)", "\)\"")
        line = line.gsub(",\"", ",")
      end
      if line.include? "\" : \/"
        line = line.gsub("\" : \/", "\" : \"\/")
        line = line.gsub("\/,", "\/\",")
      end
			if line !~ /bye/
			  array << line
			end
		end
	end
	fh.close
	doc = Yajl::Parser.parse(array)
	return doc
end

###MAIN####
object = digestFile(ARGV[0])["inprog"]

object.each do |key|
  #Remove Active or Inactive
  if options[:active] != NIL
    if options[:active]
      if key["active"].equal? false
        next
      end
    else
      if key["active"].equal? true
        next
      end
    end
  end
  #Check if a wanted Op type
  if options[:ops] != NIL
    if ! options[:ops].include? key["op"]
      next
    end
  end
  #Check if a wanted Opid
  #puts "comparing #{options[:opid]}"
  if options[:opid] != NIL
    if options[:opid] != key["opid"]
      next
    end
  end
  #Check if a wanted NS
  if options[:ns] != NIL
    if ! (options[:ns] == key["ns"])
      next
    end
  end
  #Check if an unwanted NS
  if options[:xns] != NIL
    if options[:xns] == key["ns"]
      next
    end
  end
  #Check if a nil NS
  if options[:nnns] == true
    if key["ns"] == ""
      next
    end
  end
  #Find Write Locks
  if options[:write] != NIL
	  if key.has_key? "lockStats"
      if key["lockStats"]
        #Find Write Locks
        if key["lockStats"]["timeLockedMicros"].has_key? "w"
          if key["lockStats"]["timeLockedMicros"]["w"] > options[:write]
            writeArray << key
          end
        end
        if key["lockStats"]["timeLockedMicros"].has_key? "W"
          if key["lockStats"]["timeLockedMicros"]["W"] > options[:write]
            writeArray << key
          end
        end
        if key["lockStats"]["timeLockedMicros"].has_key? "write"
          if key["lockStats"]["timeLockedMicros"]["write"] > options[:write]
            writeArray << key
          end
        end
      end
    end
  end
    #Find Read Locks
  if options[:read] != NIL
    if key["lockStats"]
      #End Find Write Locks
      if key["lockStats"]["timeLockedMicros"].has_key? "r"
        if key["lockStats"]["timeLockedMicros"]["r"] > options[:read]
          readArray << key
        end
      end
      if key["lockStats"]["timeLockedMicros"].has_key? "R"
        if key["lockStats"]["timeLockedMicros"]["R"] > options[:read]
          readArray << key
        end
      end
      if key["lockStats"]["timeLockedMicros"].has_key? "read"
        if key["lockStats"]["timeLockedMicros"]["read"] > options[:read]
          readArray << key
        end
      end
    end
  end
  #Find Seconds running
  if options[:seconds] != NIL
    if key.has_key? "secs_running"
      if key["secs_running"] > options[:seconds]
        secsArray << key
      end
    end
  end
  if options[:yield] != NIL
    if key.has_key? "numYields"
      if key["numYields"] > options[:yield]
        yieldsArray << key
      end
    end
  end
  if options[:seconds] == NIL && options[:read] == NIL && options[:write] == NIL && options[:yield] == NIL
    allArray << key
  end
end

#Output Section
if options[:read] != NIL
  readArray.sort_by { |k| k["lockStats"]["timeLockedMicros"]["r"] }
  if options[:json]
    readArray.each do |jsout|
      puts Yajl::Encoder.encode(jsout)
    end
  else
    puts readArray
  end
end
if options[:write] != NIL
  writeArray.sort_by { |k| k["lockStats"]["timeLockedMicros"]["w"] }
  if options[:json]
    writeArray.each do |jsout|
      puts Yajl::Encoder.encode(jsout)
    end
  else
    puts writeArray
  end
end
if options[:seconds] != NIL
  secsArray.sort_by { |k| k["secs_running"] }
  if options[:json]
    secsArray.each do |jsout|
      puts Yajl::Encoder.encode(jsout)
    end
  else
    puts secsArray
  end
end
if options[:yield] != NIL
  yieldsArray.sort_by { |k| k["numYields"] }
  if options[:json]
    yieldsArray.each do |jsout|
      puts Yajl::Encoder.encode(jsout)
    end
  else
    puts yieldsArray
  end

end
if options[:seconds] == NIL && options[:read] == NIL && options[:write] == NIL && options[:yield] == NIL
  if options[:json]
    allArray.each do |jsout|
      puts Yajl::Encoder.encode(jsout)
    end
  else
    puts allArray
  end
end
