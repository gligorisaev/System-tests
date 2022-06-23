*** Settings ***
Library    SSHLibrary
Library    String
Library    Dialogs

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.37    #Insert the IP address if the default should not be used
${USERNAME}       pi    #Insert the username if the default should not be used
${PASSWORD}       Alex210295    #Insert the password if the default should not be used
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
    Should Contain    ${output}    ${version}    #checking that the output of tedge -V returns the version which was installed
    Log    ${output}

call tedge -h
    ${output}=    Execute Command    tedge -h    #execute command to call help
    Should Contain    ${output}    USAGE:    #checks if USAGE: exists
    Should Contain    ${output}    OPTIONS:    #checks if OPTIONS: exists
    Should Contain    ${output}    SUBCOMMANDS:    #checks if SUBCOMMANDS: exists
    Log    ${output}

call tedge -h -V
    ${output}=    Execute Command    tedge -h -V   #execute command to call help and check the version at same time
    Should Contain    ${output}    ${version}    #checking that the output of tedge -V returns the version which was installed
    Should Contain    ${output}    USAGE:    #checks if USAGE: exists
    Should Contain    ${output}    OPTIONS:    #checks if OPTIONS: exists
    Should Contain    ${output}    SUBCOMMANDS:    #checks if SUBCOMMANDS: exists
    Log    ${output}

call tedge help
    ${output}=    Execute Command    tedge help    #execute command to call help
    Should Contain    ${output}    USAGE:    #checks if USAGE: exists
    Should Contain    ${output}    OPTIONS:    #checks if OPTIONS: exists
    Should Contain    ${output}    SUBCOMMANDS:    #checks if SUBCOMMANDS: exists
    Log    ${output}

tedge config list
    ${rc}    Execute Command    tedge config list    return_stdout=False    return_rc=True    #executing tedgeconfig list and expect return code 0
    Should Be Equal As Integers    ${rc}    0
    Log    ${rc}

*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}