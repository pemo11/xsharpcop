# XSharpCop

Current version 0.4 from 10/04/2024

## A simple static source code analyzer for X# with rules based on a PowerShell script and a _WinForms GUI_

The idea for this tool was that I use _NDepend_ a lot but it has two disadvantages for me:

1. It does not support X# on a source code level (and it probably never will) - that means that some queries are not possible
2. It requires separate licences for my laptop and my desktop PC (which is quite expensive)

Since I am mostly interested in metrics like LOC, CC, simple naming conventions and the usage of comments, I don't need most of the functionality that _NDepend_ has to offer. And I am not using it as part of a CI pipeline.

And since I couldn't find any static code analyzer for X# I had to make my own and hopefully provide some value for other X# developers.

Why PowerShell? Because I use it a lot since day 1 (2006) and its a powerfull and flexible scripting language for .Net. Because of its object pipeline I don't have to use LINQ (which would be possible) for doing queries like

That means, that the codebase can be queried either as part of the GUI tool or in the command line if the XSharpCop module had been loaded and a project had been analyzed (I will explain later how to do this):

For example:
```PowerShell
Get-Class | Where-Object { $_.Constructor.LOC -gt 100}
```

_Get-Class_ is the name of a function in the PowerShell module. It gets all the class definitions based on the last codebase as objects with certain properties-

One property is _Constructor_. Since its an object itself it offers properties like _LOC_.

So, the query first gets all class definitions as objects and then filters out those who have constructors with more than 100 lines of code (LOC).

Using X#, C# or maybe Python would not offer that interactivity (and it would be much more effort to implement it).

The command line is just an option for every X# devloper that is already familiar with the commandline. But its definitely more convenient to use _XSharpCop_ as a WinForms app.

---
How to run XSharpCop as a GUI
---

Requirements are PowerShell 7.x which has to be downloaded and installed first:

[https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4]

The programm has to be started by starting _Start.ps1_ either in VS Code or in the command line:

```PowerShell
.\start.ps1
```

_Start.ps1_ does nothing more than loading the _System.Windows.Forms_ assembly and starting _XSharpCopUI_V1.ps1_. That is necessary because I have not found yet out how to a load an assembly (like _System.Windows.Forms_) for a psm1 file that only contains a class definition. Although the assembly had been loaed its not available for the psm1 file.

Otherwise _XSharpCopUI_V1.ps1_ is the main script that contains the Window definition and the program logic. All the other ps1/psm1 files either contain helper functions or class definitions.

Ignore the warning that is shown each time due to fact that some function names do not use an "approved verb" in their name.

The rest should be self explanatory:

1. load a xsproj file
2. Either analyze the project or load a rule file and apply it

The main idea is that users can define their own rules within a yaml file.

There are a few rules in the _Rules_ folder like

```yaml
title: Alle Klassen ohne Kommentarblock
name: ClassCommentsRule1
object: Class
property: HasComment
operator: Equal
value: $false
```

This rule should find all class definitions without a preceding comment block.

Or for finding constructors with more than 50 lines of code:

```yaml
title: Alle Konstruktoren mit mehr als 50 Zeilen Code
name: Constructor50Rule
object: Constructor
property: LOC
operator: GreaterThan
value: 50
```

The _object_ has to be _class_, _constructor_, _method_ or _property_. The property has to be one of the custom properties for that type like _HasComment_ or _CC_ or _LOC_. The operator has to be _Greater_, _GreaterThan_, _Equal_ etc. (they are all defined in one of the psm1 files). And the _value_ the value to compare the property with.

It works with these simple rules which is good.

Its **not** possible to combine conditions or rules. Implementing the logic is not too much effort but providing a UI interface and all the testing is a bit of a challenge.

---
How to run XSharpCop for the command line
---

*** not ready yet (sorry)

---
Release history  
---

0.4 (10/04/24) - The current version 0.4 works as expected (but I think there is a bug because sometimes the displayed class name in the gridview is not the name of class).

It does not work with nested class definitions so far. This would be also not so difficult to fix but I have not had the time and energy to implement this.

The calculcation of the _Cyclomatic Complexity_ is done by going through each line of the source code and counting the relevant statements. It would be probably much easier to use the Roslyn libraries that the X# compiler is using. Again, I had not yet time and energy to try this out.

It was already a lot of work and testing to come this far. And without my PowerShell experience it would have been much more work.

## Where the name comes from

There used to be a _FxCop_ tool for .Net Applications from Microsoft many years ago. It was (or still is?) a static source code analyzers that use, like _NDepend_, binary files. 

its now called _legacy FxCop_ and Microsoft recommendes to use the Roslyn analyzers instead.

A short description of _FxCop_ is on Wikipedia [https://en.wikipedia.org/wiki/FxCop].

## Final words

I really hope that some X# developers find these tool usefull and have suggestions for improvement or implement them on their own by forking the repo.

My e-mail address is info@activetraining.de

Peter Monadjemi

