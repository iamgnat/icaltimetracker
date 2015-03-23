# iCalTimeTracker #
I have always hated time tracking. Not because I wish to hide what I'm doing from others, but because almost every time sheet application I have been forced to use over the years has been horrible to use.

Invariably my dis-like of the application causes me to avoid submitting my time until I have no choice. Of course by that time I forget what I've been doing and end up winging it.

Shortly before leaving my job in 2007 I started using Apple's iCal to track my time by creating events for the time I spent doing something. At that time it was simplistic in the extreme in that all the events were in a single calendar.

I kept this up through my new job and expanded to using different calendars for different projects (DoD contractors are really anal about wanting to know exactly where you've spent your time, or at least mine was). This gave me a nice visual look at my work and was easy enough to count up at the end of the day/week, but at least once a month a demand would come down for a more accurate time accounting than our time tracking systems (as a sub we had to fill out two and neither broke time down very well) and manually counting my time up from iCal grew tiresome about half way through the first time.

Thus iCalTimeTracker was born. It's early life was a Perl script that processed the ICS files and generated a web page that my manager/team mates could look at. No one besides me looked at it, so it became a Cocoa App with many more features.

I've modified it a few times over the years since and continued to use it even after moving to a new company (yay for being back in the private sector!). One other person used it some in my last group, but now a few people have seen it at my new place and want it so I've decided to throw it over the wall and make it OSS.

Hopefully others will find it useful too. If you do but there is something that would make it more useful, submit a feature request and I'll try to get it added if I think it makes sense.

As I specialize in process automation I always intended to have iCalTaskTracker actually submit the time directly to the evil time sheet apps, but I've never gotten around to it. Maybe one day... ;-)