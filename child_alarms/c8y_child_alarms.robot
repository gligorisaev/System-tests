*** Settings ***
Documentation    Testing the child device alarm message feature
...              build to be used: https://github.com/thin-edge/thin-edge.io/actions/runs/2817528444  
...              Precondition: thin-edge.io is installed, and DUT is connected to Cumulocity

Library    SSHLibrary
Library    Browser


Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.100.120    #Insert the IP address if the default should not be used
${USERNAME}       pi    #Insert the username if the default should not be used
${PASSWORD}       thinedge    #Insert the password if the default should not be used
${url}     https://gligor.latest.stage.c8y.io/
${user}    gligor
${pass}    Ian@240821

*** Tasks ***

Normal case when the child device does not exist on c8y cloud
# Log in to Cumulocity
    Open Browser    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible    #waits for Log in to be visible
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@c8yicon='th']    visible
    Click    //i[@c8yicon='th']
    Wait For Elements State    a[title='Device management'] c8y-app-icon i    visible
    Click    a[title='Device management'] c8y-app-icon i
    Wait For Elements State    //span[normalize-space()='Management']    visible
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Devices']    visible
    Click    //span[normalize-space()='Devices']
    Wait For Elements State    //span[normalize-space()='All devices']    visible
    Click    //span[normalize-space()='All devices']
    Wait For Elements State    //a[@title='child_alarms']    visible
    Click    //a[@title='child_alarms']

# Sending child alarm
    Execute Command    sudo tedge mqtt pub 'tedge/alarms/critical/temperature_high/external_sensor' '{ "message": "Temperature is very high", "time": "2021-01-01T05:30:45+00:00" }' -q 2 -r
    


*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
