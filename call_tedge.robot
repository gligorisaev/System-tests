*** Settings ***
Library    SSHLibrary

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.37
${USERNAME}       pi
${PASSWORD}       Alex210295

*** Tasks ***

Install thin-edge.io
    ${output}=    Execute Command    curl -fsSL https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/get-thin-edge_io.sh | sudo sh -s
    Log    ${output}


*** Keywords ***

Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}