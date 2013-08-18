Day.fm
======

Log your Last.fm Top Weekly Artists and Tracks to your Day One journal

![Screenshot](https://raw.github.com/MattbookPro/Day.fm/master/dayfm.png)

---

This simple script has a couple requirements in order to run:

1. You must have the Day One mac app installed (you can get it [here](http://bit.ly/DayOneMac))

2. Install the Day One CLI (you can get that [here](http://dayoneapp.com/downloads/dayone-cli.pkg))


3. If you run into any problems with the json ruby gem, install the Ruby JSON tools.  *(In the terminal run the command `$ gem install json`)*

---

To run the script:

1. Change the `username` variable at line 95 to your Last.fm username. Save the script.

2. Go into the terminal and run the following command: `$ ruby [PATH TO SCRIPT]/dayfm.rb` *(i.e. `$ ~/Documents/Dayfm/dayfm.rb`)*

I don't like that it has to be run manually, so I've been looking into getting OS X to run it for me on a schedule (like on Sundays when the new charts for the last week are released). If anybody has any suggestions about how to do this, email me at apps@mattbookpro.com.
