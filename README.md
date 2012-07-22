bau
===

Old code preservation - bau is a build-system experiment I wrote around 2004-2005.

The software was an experiment to see how I might fix some of the frustrations I
experienced with build systems I'd used over the years.  I've worked with
mainstream build tools (various flavours of make, ant, etc.) that had their strong
points, but still sucked in various ways. I've looked at obscure tools that seemed
much better, but never had a chance to try them in a real project (e.g. QEF.)

Goals
=====

Tell the system what you *want*, not how to do it.

Human-readable build scripts.

Source control and software construction (i.e. running a build) are orthogonal concepts.

Don't repeat yourself.

All artifacts must be up to date after a build.

Some things that follow on from the goals:

Don't just rely on timestamps to determine if a file is out of date!  Changing a compiler flag, say for optimization level, should trigger a rebuild of any .o files affected by the flag!)

How'd it work out?
==================

It never got much beyond a toy project. The tool can build simple projects. It was working
mostly for C programs and libraries.  It did provide a chance to take bash scripting to a new level -
there are interesting shell functions here that I've used in other projects since.

License
=======

The code is covered by an MIT license. 
