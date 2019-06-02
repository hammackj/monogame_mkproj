# Monogame Make Project

This is a simple bash script that will generate a Monogame Solution and 3 projects. 
    1. Game Project, this is used to hold the Program.cs for each platform
    2. Shared Game Project, this is used to hold all game code shared across all the platforms you want to use.
    3. Engine Project, this is used for all "engine" type code you want to share in other projects

Simple enough setup for starting a new project or gamejam. The resulting solution will compile on Windows / Linux and OSX without any issue. I work mostly from OSX but the resulting .sln worked fine in Visual Studio 2019 after making it pull down all the Nuget packages. I am sure it would also work in bash for Windows.

## Prerequisites

* Please be sure to download and install Monogame first, you can find it here: http://www.monogame.net/downloads/.

* I prefer Visual Studio code, so install that also: https://code.visualstudio.com/Download

* Install the following extensions
    - C#
    - C# Extensions
    - C# FixFormat

* Install the Monogame templates for dotnet cli.

   dotnet new --install MonoGame.Template.CSharp

## Usage

The script is fairly simple to use ```monogame_mkproj <Project Name> [Engine Name]```

- This will create a folder with the Solution and two projects PROJECT.Desktop and Engine. You can pass a second command line arugment to rename Engine to whatever, like Project.Shared. 

- The three projects are created as Monogame DesktopGL applications. This type seemed to be the best for working on all desktop platforms.

- References are Added to the projects and the the Desktop app will depend on the `Engine` and `Project.Sharded`. References to Monogame are also added during this stage.

- Nuget packages are restored and installed for use.

- Some editing of the default generated files is done to remove extra files.

- A .gitignore is created ignoring all the bin/ obj/ directories

- 3 shell scripts are generated to build and run the project.

- A blank readme is generated

- A git repo is setup and the exisiting code is commited.