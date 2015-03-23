
## General ##
For normal circumstances, you do not need to interact directly with iCalTaskTracker yourself. It's designed to simply run and keep itself up to date with your iCal information. The exception is if you wish to force it to refresh it's data before it's next auto-refresh.

The basic function of iCalTaskTracker is that it reads designated iCal calendars (based on their name) and uses the length of the events to calculate your "hours worked.

The idea is to allow your to track your hours in iCal by creating events for the work that you do. This inherently (via iCal) gives you a view of what you have been doing and even allows you to store details about what you did via the event name and/or the event notes.

What iCal doesn't give you is a quick way to add up all the events to determine hour many hours you've worked for a given period, which is what iCalTimeTracker presents for you.

### Calendar Naming ###
To utilize iCalTimeTracker you simply need to create correctly named calendars and add events to them.

By default iCalTimeTracker processes any calendar whose name ends with " Hours" (note the leading space and case) (e.g. "My Project Hours"). You can change the default naming pattern on the _General_ tab of the preferences. You have three options you can select from:

  * Starts with - Matches all calendars that start with this string.
  * Ends with - Matches all calenders that end with this string.
  * Matches REGEX - Allows you to use a Perl Compatible Regular Expression (PCRE) to match calendars.

Technically speaking, the _Starts with_ and _Ends with_ options are regular expressions as well with the ^ and $ anchors explicitly added to them. The _REGEX_ option does not add the regex anchors to your pattern (so you can match anywhere in the calendar name).

The string (pattern) that is matched to identify if a calendar should be used with be removed for display in iCalTimeTracker. For example, if you are using the default of "Ends with: ' Hours'" then "My Project Hours" will be displayed in iCalTimeTracker as "My Project".

### Row Coloring ###
The color of the rows in iCalTimeTracker's tables is determined by the color of the calender as it is configured in iCal.

### Data Refresh ###
By default your iCal data is re-read every five minutes. You can adjust this time in the _General_ tab of the iCalTimeTracker preferences. If you need to re-process the data before the next scheduled refresh, simply use the _Refresh Now_ button on the main window.

### Calculating Time ###
#### Start Of Week ####
On the _Work Days_ tab of the iCalTimeTracker preferences, you may select the day of the week that your billing week starts. The default is Sunday for a Sunday - Saturday schedule, and selecting Wednesday would give you a Wednesday - Tuesday schedule.

This option only effects the _Weekly_ view.

#### Percentage Worked ####
The calculation for the _Percentage Worked_ values can be controlled by setting your _Work Hours_ on the _Work Days_ tab of the iCalTimeTracker preferences. Use these values to set what your expected number of hours should be for the given day. For days that you enter 0, any hours entered for that day of the week (via iCal) will be calculated as 100%.

### Adding Time ###
To add time, simply create an event in iCal that belongs to a monitored calendar. iCalTimeTracker can process both regular and all-day events.

For regular events, the length of the event is used to determine the amount of time worked. If the event spans the midnight boundary of multiple buckets (e.g. any midnight for the _Daily_ tab or Saturday/Sunday for the _Weekly_ tab), then the event's time is broken up into the correct buckets (e.g. an event that starts at 2300 and ends at 0200 the next day would put 1 hour into the first day's bucket and 2 hours into the second).

For all day events you have two ways to represent the time. The first is the default which recognizes the event as 8 hours. The second option is to start the name of the event with a number (e.g. "4: did something") in which case the number will be treated as the number of hours to use (e.g. the previous example would be considered as 4 hours). If you use the naming option to specify the hours and the value is less than 1 or greater than 24, the default (currently 8) value is used instead. At this time a single multi-day event (all-day event that spans multiple days) is not supported and the result is undefined.


### Non-local calendars ###
Both local and remote calendars are supported, however delegated calendars (like additional calendars on a Google account) are not supported.

## iCal ##
A screen shot of a populated week in iCal:
![http://icaltimetracker.googlecode.com/svn/wiki/iCal.png](http://icaltimetracker.googlecode.com/svn/wiki/iCal.png)

## Daily ##
A screen shot of the _Daily_ tab in iCalTimeTracker:
![http://icaltimetracker.googlecode.com/svn/wiki/daily.png](http://icaltimetracker.googlecode.com/svn/wiki/daily.png)