*** Settings ***
Library    SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}            192.168.1.130   
${USERNAME}        pi
${PASSWORD}        thinedge

*** Test Cases ***
Test Cases
    ${output}=    Execute Command   uname -m
    Log    ${output}


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
