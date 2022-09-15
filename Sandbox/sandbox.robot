#Command to execute:    robot -d \results --timestampoutputs --log health_tedge_mapper.html --report NONE health_tedge_mapper.robot

*** Settings ***
Library    Browser
Library    SSHLibrary 
Library    MQTTLibrary
Library    String
Library    CSVLibrary
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections

*** Variables ***
${HOST}           192.168.1.130
${USERNAME}       pi
${PASSWORD}       thinedge    #crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=          
${Version}        0.*
${download_dir}    /home/pi/
${url_dow}    https://github.com/thin-edge/thin-edge.io/actions
# ${user_git}    crypt:3Uk76kNdyyYOXxus2GFoLf8eRlt/W77eEkcSiswwh04HNfwt0NlJwI7ATKPABmxKk8K1a8NsI5QH0w8EmT8GWeqrFwX2    
# ${pass_git}    crypt:IcTs6FyNl16ThjeG6lql0zNTsjCAwg5s6PhjRrcEwQ9DVHHRB4TjrGcpblR6R1v7j9oUlL3RzwxGpfBfsijVnQ==    
${url}    https://qaenvironment.eu-latest.cumulocity.com/
${url_tedge}    qaenvironment.eu-latest.cumulocity.com
${user}    qatests
${pass}    Alex@210295    #crypt:34mpoxueRYy/gDerrLeBThQ2wp9F+2cw50XaNyjiGUpK488+1fgEfE6drOEcR+qZQ6dcjIWETukbqLU=    


*** Tasks ***
Sending your first telemetry data
    # #Sending data to Cumulocity is done using MQTT over topics prefixed with c8y. Any messages sent to one of these topics will be 
    # #forwarded to Cumulocity. The messages are expected to have a format specific to each topic. Here, we use tedge mqtt pub a raw 
    # #Cumulocity SmartRest message to be understood as a temperature of 20 Celsius.
    # ${rc}=    Execute Command    tedge mqtt pub c8y/s/us 211,20    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    # Should Be Equal    ${rc}    ${0}
    # #To check that this message has been received by Cumulocity, navigate to "Device Management/Devices/All devices/<your device id>/Measurements". 
    # #You should observe a "temperature measurement" graph with the new data point.
    New Page    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
    Click    //button[normalize-space()='Agree and proceed']
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@class='icon-2x dlt-c8y-icon-th']    visible
    Click    //i[@class='icon-2x dlt-c8y-icon-th']
    Wait For Elements State    //span[normalize-space()='Device management']    visible
    Click    //span[normalize-space()='Device management']
    Wait For Elements State    //span[normalize-space()='Devices']    visible
    Click    //span[normalize-space()='Devices']
    Wait For Elements State    //span[normalize-space()='All devices']    visible
    Click    //span[normalize-space()='All devices']
    Sleep    2s
    Wait For Elements State    div[ng-class='truncated-cell-content']    visible
    # Click    //a[@title='${DeviceID}']
    Click    //a[@title='ST13092022150758']
    Wait For Elements State    //span[normalize-space()='Measurements']    visible
    Click    //span[normalize-space()='Measurements']
    Wait For Elements State    //body/c8y-ui-root[@id='app']/c8y-bootstrap/div/div/div/div[@id='c8y-legacy-view']/div[@ng-if='vm.widthSet && vm.authState.hasAuth']/div[@ng-controller='measurementsCtrl as ctrl']/c8y-list-pagination[@items='supportedMeasurements']/div/div/c8y-measurements-fragment-chart[@fragment='m']/div/div/c8y-chart[@datapoints='vm.dataPoints']/div[2]//*[name()='svg'][1]/*[name()='rect'][1]
    Click    //span[contains(text(),'More…')]
    Click    (//button[@title='Download as CSV'][normalize-space()='Download as CSV'])[2]
    Wait For Elements State    //a[normalize-space()='Download']    visible
    ${dl_promise}          Promise To Wait For Download    ${download_dir}report.zip
    Click    //a[normalize-space()='Download']
    ${file_obj}=    Wait For  ${dl_promise}
    Sleep    5s

    Put File    ${download_dir}report.zip


    ${rc}=    Execute Command    unzip report.zip -d /home/pi/download    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

    Execute Command    cd /home/pi/download

    ${report}=    Execute Command    ls
    Log    ${report}

Read csv file to a list example test
    @{list}=  Read Csv File To List    ${download_dir}3203.c8y_TemperatureMeasurement.csv
    Log  ${list[0]}
    Log  ${list[1]}



# Read CSV file
#     # ${rc}=    Execute Command    unzip report.zip    return_stdout=False    return_rc=True
#     # Should Be Equal    ${rc}    ${0}
#     ${csv}=    Get File    /home/pi/3203.c8y_TemperatureMeasurement.csv
#     @{read}=    Create List    ${csv}
#     @{lines}=    Split To Lines    @{read}    1


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

