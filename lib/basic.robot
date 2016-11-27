*** Keywords ***
I successfully run
    [Arguments]   @{args}
    I run         @{args}
    It returns    0

I install
    [Arguments]         ${package}
    I successfully run  yum  install  -y  ${package}
    It returns          0
