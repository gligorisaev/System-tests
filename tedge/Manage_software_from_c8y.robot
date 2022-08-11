*** Settings ***
Documentation    GIVEN    

Library    SSHLibrary
Library    Browser
Library    Dialogs
# Library    CryptoLibrary    variable_decryption=True


Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections


*** Variables ***
${HOST}           192.168.100.110    #Insert the IP address if the default should not be used
${USERNAME}       pi    #Insert the username if the default should not be used
${PASSWORD}       thinedge    #Insert the password if the default should not be used
${url}     https://gligor.latest.stage.c8y.io/
${user}    gligor
${pass}    Ian@240821


*** Tasks ***

Create download folder on Documentation
    Execute Command    mkdir downloads
    

C8Y Part
# Log in to Cumulocity
    Open Browser    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible    #waits for Log in to be visible
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@c8yicon='th']    visible
    Click    //i[@c8yicon='th']
# Add Software to repository
    Wait For Elements State    a[title='Device management'] c8y-app-icon i    visible
    Click    a[title='Device management'] c8y-app-icon i
    Wait For Elements State    //span[normalize-space()='Management']    visible
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Software repository']    visible
    Click    //span[normalize-space()='Software repository']
    Click    //a[@title='test sw']
    Wait For Elements State    //button[@title='Add software']    visible
    Click    //button[@title='Add software']
    Wait For Elements State    //i[@class='dlt-c8y-icon-plus-square']    visible
    Type Text    //input[@id='softwareVersion']    2.0.0
    Click    //label[@title='Provide a file path']//span[1]
    Wait For Elements State    //input[@placeholder='e.g. http://example.com/binary.zip (required)']    visible
    Type Text    //input[@placeholder='e.g. http://example.com/binary.zip (required)']    rolldice_1.16-1+b1_armhf_test.deb

    Pause Execution

    # Wait For Elements State    //c8y-typeahead[@name='softwareName']//i
    # Click    //c8y-typeahead[@name='softwareName']//i
    # Click    //span[normalize-space()='test sw']
    # Sleep    1s
    # Wait For Elements State    //input[@id='softwareDescription']    visible
    # Type Text    //input[@id='softwareDescription']    Automated test run

     

# Remove file and folder
#     Execute Command    rmdir downloads
    
*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
    