*** Settings ***
Documentation    Run connection test while being connected and check the positive response in stdout
...              disconnect the device from cloud and check the negative message in stderr

Library    SSHLibrary
Library    CryptoLibrary    variable_decryption=True
Library    Dialogs

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections


*** Variables ***
${HOST}           192.168.0.37    #Insert the IP address if the default should not be used
${USERNAME}       crypt:v/xPnyEmjvBm9W/wY+dBC8zF/PNDJTGkuQE7s8/W/zTGjb1ONn70YpIXblngo00VJ9E=    #Insert the username if the default should not be used
${PASSWORD}       crypt:Lqjbi1ivrpopGxIaKPHPWlW+gLykaMCSa/tRiMl0GFA38d4nIDe9e4TYl5dQHZAhIGdzkOA3TBUKHA==    #Insert the password if the default should not be used

*** Tasks ***
tedge_connect_test_positive
    ${stdout}=    Execute Command    sudo tedge connect c8y --test
    Should Contain    ${stdout}    Connection check to c8y cloud is successful.
    Log    ${stdout}

tedge_connect_test_negative
    Execute Command    sudo tedge disconnect c8y
    ${stdout}    ${stderr}=    Execute Command    sudo tedge connect c8y --test    return_stderr=True
    Should Contain    ${stderr}    Error: failed to test connection to Cumulocity cloud.
    Log    ${stderr}
    Execute Command    sudo tedge connect c8y

*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}