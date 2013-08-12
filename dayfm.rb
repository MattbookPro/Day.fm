#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'net/http'
require 'date'

# basic variables of the url strings
base_url = "http://ws.audioscrobbler.com/2.0/?format=json"
if ARGV.empty?
  puts "Need username argument"
  abort
else
  username = ARGV[0] # Argument from command line
end
apikey = "23d8ee657fa0239be29f99812b41dcbf"
chartmethod = "user.getweeklychartlist"
artistmethod = "user.getweeklyartistchart"
trackmethod = "user.getweeklytrackchart"


###
# CHARTS LIST
###

# Build url for retreiving weekly charts list
charturl = "#{base_url}&method=#{chartmethod}&user=#{username}&api_key=#{apikey}"

# Retreive json data from charturl, store in charts hash
resp = Net::HTTP.get_response(URI.parse(charturl))
data = resp.body
charts = JSON.parse(data)

# Get from and to unix timestamp dates for the chartno specified
chartno = -1 # Last item in hash
fromdate = charts['weeklychartlist']['chart'][chartno]['from']
todate = charts['weeklychartlist']['chart'][chartno]['to']


###
# TOP ARTISTS CHART
###

# Build url for weekly artist chart
artisturl = "#{base_url}&method=#{artistmethod}&user=#{username}&from=#{fromdate}&to=#{todate}&api_key=#{apikey}"

# Retreive json data from trackurl, store in tracks hash
resp = Net::HTTP.get_response(URI.parse(artisturl))
data = resp.body
artists = JSON.parse(data)


###
# TOP TRACKS CHART
###

# Build url for weekly track chart
trackurl = "#{base_url}&method=#{trackmethod}&user=#{username}&from=#{fromdate}&to=#{todate}&api_key=#{apikey}"

# Retreive json data from trackurl, store in tracks hash
resp = Net::HTTP.get_response(URI.parse(trackurl))
data = resp.body
tracks = JSON.parse(data)


###
# ENTRY STRING
###
# Header
fromdatestr = Time.at(fromdate.to_i).strftime("%B %e")
todatestr = Time.at(todate.to_i).strftime("%B %e")
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

date = Time.at(todate.to_i)
%x{echo "#{entry}" | /usr/local/bin/dayone -d="#{date}"  new}

