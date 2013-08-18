#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'net/http'
require 'date'

def makeEntry
	###
	# TOP ARTISTS CHART
	###
	
	# Build url for weekly artist chart
	artisturl = "#{$base_url}&method=#{$artistmethod}&from=#{$fromdate}&to=#{$todate}"
	
	# Retreive json data from trackurl, store in tracks hash
	resp = Net::HTTP.get_response(URI.parse(artisturl))
	data = resp.body
	artists = JSON.parse(data)
	
	
	###
	# TOP TRACKS CHART
	###
	
	# Build url for weekly track chart
	trackurl = "#{$base_url}&method=#{$trackmethod}&from=#{$fromdate}&to=#{$todate}"
	
	# Retreive json data from trackurl, store in tracks hash
	resp = Net::HTTP.get_response(URI.parse(trackurl))
	data = resp.body
	tracks = JSON.parse(data)
	
	
	###
	# ENTRY STRING
	###
	# Header
	fromdatestr = Time.at($fromdate.to_i).strftime("%B %e")
	todatestr = Time.at($todate.to_i).strftime("%B %e")
	entry = "# Last.fm Weekly Report"
	entry.concat("\n")
	entry.concat("## #{fromdatestr} -- #{todatestr}")
	entry.concat("\n\n")
	entry.concat("----")
	entry.concat("\n")
	
	# Top Artists
	entry.concat("### Top Artists")
	entry.concat("\n\n")
	artists['weeklyartistchart']['artist'].each do |key, value|
	  entry.concat("**" + key['name'].gsub("*","") + "**  —  ")
	  entry.concat("*(" + key['playcount'] + " plays)*\n")
	end
	entry.concat("\n\n")
	entry.concat("----")
	entry.concat("\n")
	
	# Top Tracks
	entry.concat("### Top Tracks")
	entry.concat("\n\n")
	tracks['weeklytrackchart']['track'].each do |key, value|
	  entry.concat("**" + key['artist']['#text'].gsub("*","") + "**  —  ")
	  entry.concat(key['name'].gsub("*","") + " ")
	  entry.concat("*(" + key['playcount'] + " plays)*\n")
	end
	
	# Get Day One formatted date string
	date = Time.at($todate.to_i)
	
	###
	# CREATE ENTRY
	###
	%x{echo "#{entry}" | /usr/local/bin/dayone -d="#{date}"  new}

end # end makeEntry() function


################
#     Main     #
################

# Open hidden .dayfmdata file for storing and retreiving the last chart date entered into journal
# If file already exists, open it for read-write
# If it does not exist, create it with read-write
if File.exist?( ".dayfmdata" )
  dataFile = File.open(".dayfmdata","r+")
  puts ".dayfmdata file opened"
else
  dataFile = File.new(".dayfmdata","w+")
  puts ".dayfmdata file created"
end

# basic variables of the url strings
username = "mattbookpro"
apikey = "23d8ee657fa0239be29f99812b41dcbf"
$base_url = "http://ws.audioscrobbler.com/2.0/?format=json&user=#{username}&api_key=#{apikey}"

$chartmethod = "user.getweeklychartlist"
$artistmethod = "user.getweeklyartistchart"
$trackmethod = "user.getweeklytrackchart"

###
# CHARTS LIST
###

# Build url for retreiving weekly charts list
charturl = "#{$base_url}&method=#{$chartmethod}"

# Retreive json data from charturl, store in charts hash
resp = Net::HTTP.get_response(URI.parse(charturl))
data = resp.body
charts = JSON.parse(data)

# Get from and to unix timestamp dates for the chartno specified
chartno = -1 # Last item in hash
$fromdate = charts['weeklychartlist']['chart'][chartno]['from']
$todate = charts['weeklychartlist']['chart'][chartno]['to']
oldtodate = charts['weeklychartlist']['chart'][-2]['to']

puts "todate: :#{$todate}"

###
# DETERMINE LAST CHART ENTERED (IF ANY)
###

arr = IO.readlines(".dayfmdata")
datefromfile = arr[0]

if datefromfile == nil # For first run, just put the most current chart into the file and makeEntry with it
  puts "file was empty"
  dataFile.syswrite(oldtodate)
  puts "file now contains oldtodate"
  puts "creating entry using the most recent chart dates"
  makeEntry
elsif datefromfile == $todate # Same week with old chart, don't makeEntry
  puts datefromfile
  puts "makeEntry not called, entry already exists"
elsif datefromfile < $todate # The date from the file is older than todate, create new entry
  makeEntry
  puts "makeEntry called, new chart found"
  dataFile.syswrite($todate)
  puts "file now contains todate"
end

dataFile.close
