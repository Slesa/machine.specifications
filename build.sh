#!/usr/bin/env bash

configuration="Debug"
framework=netcoreapp1.0
pattern="Source/*Specs* Source/*Test*"

echo configuration = ${configuration}

# Colors
RED="\033[0;31m"
GREEN="\033[1;32m"
NC="\033[0m" # No Color

function info {
    echo "${NC}"$1
} 

function success {
    echo "${GREEN}"$1
} 

function error {
    echo "${RED}"$1
}

function restore {
    info "Restoring packages..."
    if dotnet restore ; then
        success "Restore succeeded" 
    else
        error "Restore failed"
    fi 
}

function buildProject {
    info "Building"
    if dotnet build $1/**/project.json -c ${configuration} -f ${framework} ; then
        success "Build succeeded"
    else 
        error "Build failed"
    fi
}

function testProject {
    info "Running tests for "
    if dotnet test $1 -c ${configuration} -f ${framework} ; then
        success "Test succeeded"
    else
        error "Test failed"
    fi
}


# Exit if any command fails
set -e

artifactsFolder="./artifacts"

if [ -d $artifactsFolder ]; then  
  rm -R $artifactsFolder
fi

restore

# Folders array
folders=( ) 

# Get all folders that match the pattern
for _dir in ${pattern} 
do 
     [ -d "${_dir}" ] && folders+=(${_dir})      
done

# Build all projects 
for _d in "${folders[@]}"
do
    buildProject $_d
done

for _d in "${folders[@]}"
do
    testProject $_d
done

revision=${TRAVIS_JOB_ID:=1}  
revision=$(printf "%04d" $revision) 

#dotnet pack ./src/PROJECT_NAME -c Release -o ./artifacts --version-suffix=$revision

info "Building and testing all done.."  