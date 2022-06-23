*** Settings ***
Library    SSHLibrary
Library    String

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.37
${USERNAME}       pi
${PASSWORD}       Alex210295
${version}

*** Tasks ***
Install thin-edge.io
    ${output}=    Execute Command    curl -fsSL https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/get-thin-edge_io.sh | sudo sh -s    #running the script for installing latest version of tedge
    ${line}    Get Line    ${output}    2    #getting the version which is installed out of the log
    ${version}    Fetch From Right    ${line}    :     #Cutting log output in order only to keep version number
    Set Suite Variable    ${version}
    Log    ${version}    #log of the output
    Log    ${output}    #log of the output

call tedge -V
    ${output}=    Execute Command    tedge -V    #execute command to check version
    Should Contain    ${output}    ${version}
    Log    ${output}

*** Keywords ***

Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}