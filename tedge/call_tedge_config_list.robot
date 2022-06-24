*** Settings ***
Library    SSHLibrary
Library    String

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.37    #Insert the IP address if the default should not be used
${USERNAME}       pi    #Insert the username if the default should not be used
${PASSWORD}       Alex210295    #Insert the password if the default should not be used
${version}

*** Tasks ***
tedge config list
    ${rc}    Execute Command    tedge config list    return_stdout=False    return_rc=True    #executing tedgeconfig list and expect return code 0
    Should Be Equal As Integers    ${rc}    0
    Log    ${rc}

*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}