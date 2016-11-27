*** Keywords ***
I successfully run
    [Arguments]   @{args}
    I run         @{args}
    It returns    0
