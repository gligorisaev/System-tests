*** Settings ***
Documentation    Validate that tedge_mapper can be started, also that tedge_mapper can be stopped
...              tedge_mapper cannot be started twice

Library    SSHLibrary
Library    CryptoLibrary    variable_decryption=True
Library    Dialogs

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections


*** Variables ***
${HOST}           192.168.88.64    #Insert the IP address if the default should not be used
${USERNAME}       pi    #Insert the username if the default should not be used
${PASSWORD}       raspberry    #Insert the password if the default should not be used


*** Tasks ***
start tedge-mapper
    ${rc}    Execute Command    sudo systemctl start tedge-mapper-c8y    return_stdout=False    return_rc=True    #executing start tedge-mapper and expect return code 0
    Should Be Equal As Integers    ${rc}    0
start tedge-mapper second time
    ${output}    Execute Command    sudo -u tedge tedge_mapper c8y    #executing start tedge-mapper for second time
    Should Contain    ${output}    Another instance of tedge-mapper-c8y is running.    
stop tedge-mapper
    ${rc}    Execute Command    sudo systemctl stop tedge-mapper-c8y    return_stdout=False    return_rc=True    #executing stop tedge-mapper and expect return code 0
    Should Be Equal As Integers    ${rc}    0
    Log    ${rc}

*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}