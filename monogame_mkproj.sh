#!/bin/bash

# monogame_mkproj.sh v0.1
# Template to install for Monogame Projects
# dotnet new --install MonoGame.Template.CSharp

# SOLUTION should be the name of the Game
# Project is a default Desktop OSX/WIN/LIN build
# ENGINE is the name of your code library/engine

if [ "$1" != "" ]; then
    SOLUTION="$1"
else
    echo "No Solution name given, Please name the project."
    exit 1
fi

PROJECT="${SOLUTION}.Desktop"

PROJECT_SHARED="${SOLUTION}.Shared"

if [ "$2" != "" ]; then
    ENGINE="$2"
else
    ENGINE="Engine"
    echo "No Engine name given using 'Engine'"
fi

# Create the Solution
dotnet new sln -o $SOLUTION
cd $SOLUTION

# Create the Projects
dotnet new mgdesktopgl -o $PROJECT
dotnet new mgdesktopgl -o $PROJECT_SHARED
dotnet new mgdesktopgl -o $ENGINE

# Add the Projects to the $SOLUTION
dotnet sln $SOLUTION.sln add $PROJECT/$PROJECT.csproj 
dotnet sln $SOLUTION.sln add $PROJECT_SHARED/$PROJECT_SHARED.csproj 
dotnet sln $SOLUTION.sln add $ENGINE/$ENGINE.csproj

# Reference $ENGINE to $PROJECT
dotnet add $PROJECT/$PROJECT.csproj reference $ENGINE/$ENGINE.csproj
dotnet add $PROJECT/$PROJECT.csproj reference $PROJECT_SHARED/$PROJECT_SHARED.csproj

# Add Monogame references, Note: The Latest versions seem to have a OpenAL Library bug fixed in 3.7.1
dotnet add $PROJECT/$PROJECT.csproj package "MonoGame.Framework.DesktopGL.Core" --version "3.7.0.7"
dotnet add $PROJECT/$PROJECT.csproj package "MonoGame.Content.Builder" --version "3.7.0.9"

dotnet add $PROJECT_SHARED/$PROJECT_SHARED.csproj package "MonoGame.Framework.DesktopGL.Core" --version "3.7.0.7"
dotnet add $PROJECT_SHARED/$PROJECT_SHARED.csproj package "MonoGame.Content.Builder" --version "3.7.0.9"

# Engine References
dotnet add $ENGINE/$ENGINE.csproj package "MonoGame.Framework.DesktopGL.Core" --version "3.7.0.7"
dotnet add $ENGINE/$ENGINE.csproj package "MonoGame.Content.Builder" --version "3.7.0.9"

# Optional Packages
dotnet add $ENGINE/$ENGINE.csproj package "ImGui.NET" --version "1.70.0"
dotnet add $ENGINE/$ENGINE.csproj package "Newtonsoft.Json" --version "12.0.2"

dotnet restore

# Remove Duplicate Program.cs, Game1.cs
rm $ENGINE/Program.cs
rm $ENGINE/Game1.cs
rm $PROJECT_SHARED/Program.cs
rm $PROJECT/Game1.cs

# Remove $PROJECT.Desktop's Content as this is Shared
rm -rf $PROJECT/Content

# Move Game1.cs to $SOLTUIONGame.cs
mv $PROJECT_SHARED/Game1.cs $PROJECT_SHARED/"${SOLUTION}Game.cs"

sed -i '' "s/Game1/${SOLUTION}Game/" $PROJECT_SHARED/"${SOLUTION}Game.cs"
sed -i '' "s/Game1/${SOLUTION}Game/" $PROJECT/Program.cs

# Fix namespaces
sed -i '' "s/namespace ${SOLUTION}.Shared/namespace ${SOLUTION}/" $PROJECT_SHARED/"${SOLUTION}Game.cs"
sed -i '' "s/namespace ${SOLUTION}.Desktop/namespace ${SOLUTION}/" $PROJECT/Program.cs

# Change $ENGINE to a Library
sed -i '' 's/WinExe/Library/' $ENGINE/$ENGINE.csproj

# Change $PROJECT_SHARED to a Library
sed -i '' 's/WinExe/Library/' $PROJECT_SHARED/$PROJECT_SHARED.csproj

# Setup .gitignore
touch .gitignore
echo "${PROJECT}/bin" >> .gitignore
echo "${PROJECT}/obj" >> .gitignore

echo "${PROJECT_SHARED}/bin" >> .gitignore
echo "${PROJECT_SHARED}/obj" >> .gitignore

echo "${ENGINE}/bin" >> .gitignore
echo "${ENGINE}/obj" >> .gitignore

# Build task script to handle various tasks for building
TASKS_SCRIPT=tasks.sh
(cat <<END
#!/bin/bash

SOLUTION=${SOLUTION}
OUTPUT=${PROJECT}/bin/Debug/netcoreapp2.0/${PROJECT}.dll

function build()
{   
    msbuild \$SOLUTION.sln
} 

function run() 
{ 
    dotnet \$OUTPUT 
}

function go()
{
    build
    run
}

function zip()
{
    zip -r \$SOLUTION.zip . -x "*.DS_Store"
}

function help()
{
    echo "Help:"
    echo ""
    echo "Commands: build, run, go, zip, help"
    echo ""
}

case "\$1" in
    build)
        build
    ;;

    run)
        run
    ;;

    go)
        go
    ;;
    
    help)
        help
    ;;

    *)
        help
    ;;
esac
END
) > $TASKS_SCRIPT

chmod +x $TASKS_SCRIPT
./$TASKS_SCRIPT go

touch README.markdown
echo "# ${SOLUTION}" >> README.markdown
echo "" >> README.markdown

git init
git add .
git commit -m "Initial Commit"

