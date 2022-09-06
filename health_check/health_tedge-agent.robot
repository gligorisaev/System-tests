#Command to execute:    robot -d \results --timestampoutputs --log health_tedge-agent.html --report NONE --variable HOST:192.168.1.120 health_tedge-agent.robot

*** Settings ***
Library    SSHLibrary 
Library    MQTTLibrary
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           
${USERNAME}       pi
${PASSWORD}       thinedge  #crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=



*** Tasks ***

Stop tedge-agent
    ${rc}=    Execute Command    sudo systemctl stop tedge-agent.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Update the service file
    ${rc}=    Execute Command    sudo sed -i '11iWatchdogSec=30' /lib/systemd/system/tedge-agent.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Reload systemd files
    ${rc}=    Execute Command    sudo systemctl daemon-reload    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start tedge-agent
    ${rc}=    Execute Command    sudo systemctl start tedge-agent.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start watchdog service
    ${rc}=    Execute Command    sudo systemctl start tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    Sleep    10s
Grab the health messages
    Open Connection And Log In
    ${mqtt}=    Write    sudo tedge mqtt sub tedge/health/#
Check PID of tedge_mapper
    ${pid}=    Execute Command    pgrep tedge_agent
    Set Suite Variable    ${pid}
Restart tedge_agent
    ${rc}=    Execute Command    sudo systemctl restart tedge-agent.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Stop watchdog service
    ${rc}=    Execute Command    sudo systemctl stop tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Recheck PID of tedge_agent
    ${pid1}=    Execute Command    pgrep tedge_agent
    Set Suite Variable    ${pid1}
Compare PID change
    Should Not Be Equal    ${pid}    ${pid1}
Remove entry from service file
    ${rc}=    Execute Command    sudo sed -i '11d' /lib/systemd/system/tedge-agent.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

 




*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

