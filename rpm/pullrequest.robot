*** Settings ***
Test Setup          Populate a Duffy node
Test Teardown       Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot
Resource            lib.robot

*** Test cases ***
I build the RPM from a Pull Request
    I scratch build the spec file in CBS
    I make the spec file unique
    I build the spec file in CBS

I wait for the repo to be populated
    On the Duffy node
    I install   yum-utils
    I add a CBS yum repo    %{BUILDTAG}-candidate
    Wait Until Keyword Succeeds     20  30s     I successfully run   yum  --setopt  metadata_expire=0  install  -y  %{SPECFILE}-pull-request-build-id(pr%{ghprbPullId}job%{BUILD_NUMBER})
