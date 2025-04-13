# Ghidra

## Modifying values/memory

To enable the change of any values, firsly we need to
enable controlling the target with editing.
`Control Target Icon (Red Circle) -> Control Target (Implicitly w/ editing)`

Now for registers, we go to the registers windows and click on:
`"Enable editting..." (Icon is like a pen and paper)`

For memory, in the memory view window we also press on:
`"Enable editting..." (Icon is like a pen and paper)`

## Seeing raw memory

`Window -> Debbuger -> New Memory View`
Set the tracker to track the stack pointer (architecture specific).
To have a better showcase of the stack also configure it to show
8 bytes for each line.

The memory view window also has a go to button, right next to 
the exit button that allows you to go to any memory address.

## The Unintuitive

For text highlighting, the middle click is used, compared
to the start left/right clicks.

## Configuring

Ghidra is extremely flexible and configurable, to set your
preferences for interfaces and information, use
`Edit -> Tool Options`

## Help

Ghidra has generally amazing features for helping and learning,
the cheatsheet, the help pages, and it even has its own training
materials.

To get to the very useful help pages, for any window or option,
hover over the thing you need help with and press F1.
Ghidra will pull up the exact help pages related to that element.

To get to the training materials, we need to have a web server that
serves the html pages they provided, on regular distros this is as
simple as going to the download folder of ghidra and running
`python3 -m http.server`
This would have opened up the webserver at localhost:8080 (http)

On NixOS first navigate to the download dir in the nix store
```bash
cd /nix/store
ls | grep ghidra-11
cd cxpx8ksnijs3151xwbyw67v4wfswnqv6-ghidra-11.3.1
cd ./lib/ghidra/docs
python -m http.server
```

Then for the classes/training material, go to http://localhost:8000/GhidraClass/Beginner/

## Source

[OpenSecurityTraining2 Dbg1102: Introductory Ghidra](https://apps.p.ost2.fyi/learning/course/course-v1:OpenSecurityTraining2+Dbg1102_IntroGhidra+2024_v2)
[Ghidra Cheatsheet](https://ghidra-sre.org/CheatSheet.html)
