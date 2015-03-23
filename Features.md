# Feature List #

  * Calculates hours worked from iCal calendars.
  * Uses the length of an event to calculate the time worked.
  * Treats all-day events as 8 hours.
    * Starting an all-day event's name with a number will use that number as the number of hours for the event rather than the default 8.
    * All-day events that span multiple days are **not** supported.
  * Shows daily, weekly, monthly, yearly, and all-time roll-ups for each calendar.
  * In addition to rolling up for each calendar, it gives a roll-up of the total hours worked for the given period (day, week, month, year).
  * Additionally it provides a _Percentage Worked_ summary for the period to show the percentage of time you've worked for that period (calculated as 8 hours a day for 5 days a week).
  * Supports non-local calendars (e.g. Google Calendar).
    * Delegate calendars are not currently supported.
  * Allows you to specify expected hours each day of the week (used for calculating percentage worked).
  * (For the weekly view) Lets you specify the day your weeks start (e.g. Mon - Sun vs Sun - Sat).