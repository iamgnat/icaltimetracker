# Introduction #

The UI for iCalTaskTracker is intended to be simplistic and straight forward.

# Details #

The main function of the UI is broken into Tabs on the main window. Each tab represents a different summary view of your time. All the tabs show roughly the same information in two tables. As well as the Tabs, there is a _Refresh Now_ button to reload the iCal data on demand, otherwise it is reloaded every 5 minutes.

The main table's rows are for each calendar it processes and the columns are the time periods the time is rolled up into. The second table shows the Total (sum of all calendars for that time period) hours and Percentage Worked.

The Percentage Worked value takes the total number possible hours for the time period and determines what percentage of that your current total is. The possible hours is calculated at 8 hours a day and 5 days a week (Monday - Friday).

The exceptions to the tabs matching are:
  * Daily contains 5 columns rather than 4 for the roll-up values.
  * The Percentage Worked value in the Daily tab for Saturdays and Sundays is always calculated as 100% of any hours you worked (or 0% if none are worked).
  * Total only contains 2 columns for it's roll-ups.
  * Total does not have a Percentage Worked summary.

## Daily ##
![http://icaltimetracker.googlecode.com/svn/wiki/daily.png](http://icaltimetracker.googlecode.com/svn/wiki/daily.png)

## Weekly ##
![http://icaltimetracker.googlecode.com/svn/wiki/weekly.png](http://icaltimetracker.googlecode.com/svn/wiki/weekly.png)

## Monthly ##
![http://icaltimetracker.googlecode.com/svn/wiki/monthly.png](http://icaltimetracker.googlecode.com/svn/wiki/monthly.png)

## Yearly ##
![http://icaltimetracker.googlecode.com/svn/wiki/yearly.png](http://icaltimetracker.googlecode.com/svn/wiki/yearly.png)

## Total ##
![http://icaltimetracker.googlecode.com/svn/wiki/total.png](http://icaltimetracker.googlecode.com/svn/wiki/total.png)