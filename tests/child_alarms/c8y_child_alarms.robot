*** Settings ***
Documentation    Testing the child device alarm message feature
...              build to be used: https://github.com/thin-edge/thin-edge.io/actions/runs/2817528444  
...              Precondition: thin-edge.io is installed, and DUT is connected to Cumulocity

Library    SSHLibrary
Library    Browser
Library    Dialogs


Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}    192.168.100.120
${USERNAME}    
${PASSWORD}    
${url}     
${user}    
${pass}    
${child_device_name}    test_sensor_qa
${dev_name}


*** Tasks ***
Normal case when the child device does not exist on c8y cloud
# Log in to Cumulocity
    New Page    ${url}
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
    Wait For Elements State    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    ${dev_name}    Get Text    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    Log    ${dev_name}
    Set Suite Variable    ${dev_name}
    Click    //a[@title='${dev_name}']
    Sleep    3s
    ${menu_list}    Get Text    //div[@class='tabContainer hidden-xs']
    Log    ${menu_list}
    Should Not Contain    ${menu_list}    Child devices  
# Sending child alarm
    Execute Command    sudo tedge mqtt pub 'tedge/alarms/critical/temperature_high/${child_device_name}' '{ "message": "Temperature is very high", "time": "2021-01-01T05:30:45+00:00" }' -q 2 -r
#Check Child device creation
    Reload
    Sleep    5s
    ${menu_list}    Get Text    //div[@class='tabContainer hidden-xs']
    Log    ${menu_list}
    Should Contain    ${menu_list}    Child devices
#Check created alarm
    Click    //span[@class='txt'][normalize-space()='Alarms']
    Wait For Elements State    //span[normalize-space()='CRITICAL']    visible
    ${alarm}    Get Text    //c8y-alarm-list[1]
    Log    ${alarm}
    Should Contain    ${alarm}    CRITICAL
    Should Contain    ${alarm}    Alarm of type 'temperature_high' raised
    Should Contain    ${alarm}    1 Jan 2021, 06:30:45
    Should Contain    ${alarm}    MQTT Device ${child_device_name}

Normal case when the child device already exists
    New Page    ${url}
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
    Wait For Elements State    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    ${dev_name}    Get Text    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    Log    ${dev_name}
    Set Suite Variable    ${dev_name}
    Click    //a[@title='${dev_name}']
    Sleep    3s
    ${menu_list}    Get Text    //div[@class='tabContainer hidden-xs']
    Log    ${menu_list}
    Should Contain    ${menu_list}    Child devices
#Sending child alarm again
    Execute Command    sudo tedge mqtt pub 'tedge/alarms/critical/temperature_high/${child_device_name}' '{ "message": "Temperature is very high", "time": "2021-01-02T05:30:45+00:00" }' -q 2 -r
    Click    //span[@class='txt'][normalize-space()='Alarms']
    Wait For Elements State    //span[normalize-space()='CRITICAL']    visible
    ${alarm}    Get Text    //c8y-alarm-list[1]
    Log    ${alarm}
#Check created second alarm
    Click    //span[@class='txt'][normalize-space()='Alarms']
    Wait For Elements State    //span[normalize-space()='CRITICAL']    visible
    ${alarm}    Get Text    //c8y-alarm-list[1]
    Log    ${alarm}
    Should Contain    ${alarm}    CRITICAL
    Should Contain    ${alarm}    2 Alarm of type 'temperature_high' raised
    Should Contain    ${alarm}    2 Jan 2021, 06:30:45
    Should Contain    ${alarm}    MQTT Device ${child_device_name}

Reconciliation when the new alarm message arrives, restart the mapper
    Execute Command    sudo systemctl stop tedge-mapper-c8y.service
    Execute Command    sudo tedge mqtt pub 'tedge/alarms/critical/temperature_high/${child_device_name}' '{ "message": "Temperature is very high", "time": "2021-01-03T05:30:45+00:00" }' -q 2 -r
    New Page    ${url}
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
    Wait For Elements State    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    ${dev_name}    Get Text    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    Log    ${dev_name}
    Set Suite Variable    ${dev_name}
    Click    //a[@title='${dev_name}']
    Sleep    3s
    Execute Command    sudo systemctl start tedge-mapper-c8y.service
#Check created second alarm
    Click    //span[@class='txt'][normalize-space()='Alarms']
    Wait For Elements State    //span[normalize-space()='CRITICAL']    visible
    ${alarm}    Get Text    //c8y-alarm-list[1]
    Log    ${alarm}
    Should Contain    ${alarm}    CRITICAL
    Should Contain    ${alarm}    Alarm of type 'temperature_high' raised
    Should Contain    ${alarm}    Jan 2021, 06:30:45
    Should Contain    ${alarm}    MQTT Device ${child_device_name}

Reconciliation when the alarm that is cleared
    Execute Command    sudo systemctl stop tedge-mapper-c8y.service
    Execute Command    sudo tedge mqtt pub 'tedge/alarms/critical/temperature_high/${child_device_name}' '' -q 2 -r
    Execute Command    sudo systemctl start tedge-mapper-c8y.service
    New Page    ${url}
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
    Wait For Elements State    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    ${dev_name}    Get Text    //td[@class='cdk-cell cdk-column-name data-record-header']//c8y-cell-renderer
    Log    ${dev_name}
    Set Suite Variable    ${dev_name}
    Click    //a[@title='${dev_name}']
    Sleep    3s

#Check existance of alarms
    Click    //span[normalize-space()='Child devices']
    Wait For Elements State    //a[@title='MQTT Device ${child_device_name}']    visible
    Click    //a[@title='MQTT Device ${child_device_name}']
    Wait For Elements State    //span[@class='txt'][normalize-space()='Alarms']    visible
    Click    //span[@class='txt'][normalize-space()='Alarms']
    ${alarm}    Get Text    //body[1]/c8y-ui-root[1]/c8y-bootstrap[1]/div[1]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/c8y-alarm-list[1]/div[1]/div[2]/div[1]/div[1]/p[1]/strong[1]
    Log    ${alarm}
    Should Contain    ${alarm}    No alarms to display.


*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
