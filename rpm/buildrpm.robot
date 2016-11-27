*** Settings ***
Test Setup          Populate a Duffy node
Test Teardown       Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot

*** Test cases ***
We build the RPM for a Pull Request
    Pass Execution if  'ghprbPullId' not in os.environ   Skipping because ghprbPullId is not set
