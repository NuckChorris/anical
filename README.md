# anical

A simple Ruby script to harvest data from animecalendar.net and output in JSON or iCal

## CLI Usage
First make sure you have all dependencies installed (or run `bundle install`)

Once all dependencies are met, you can invoke it via `ruby ./anical.rb`.

 * `-j`, `--json` &mdash; Generate JSON instead of iCal file
 * `-ical` &mdash; Generate iCal file (default)
 * `-q`, `--quiet` &mdash; Hide output from timers
 * `-o FILE`, `--output FILE` &mdash; Output to a file (default: standard output)
