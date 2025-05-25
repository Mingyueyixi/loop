# loop
a retry tool for windows commands

README_zh.md

# Usage

when you want to run a command multiple times, you can use loop command.

like this:

```
loop git push

```

it will run the command "git push" **1024** times or until the command succeeds.

This can effectively reduce the failure caused by network problems when the network is not good or commands need to be executed frequently.

