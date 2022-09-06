#Command to execute:    robot -d \results --timestampoutputs --log health_c8y-log-plugin.html --report NONE --variable HOST:192.168.1.120 QA/System-tests/health_check/health_c8y-log-plugin.robot

*** Settings ***
Library    SSHLibrary 
Library    MQTTLibrary
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           
${USERNAME}       pi
${PASSWORD}       crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=

*** Tasks ***
Stop c8y-log-plugin
    ${rc}=    Execute Command    sudo systemctl stop c8y-log-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Update the service file
    ${rc}=    Execute Command    sudo sed -i '10iWatchdogSec=30' /lib/systemd/system/c8y-log-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Reload systemd files
    ${rc}=    Execute Command    sudo systemctl daemon-reload    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start c8y-log-plugin
    ${rc}=    Execute Command    sudo systemctl start c8y-log-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start watchdog service
    ${rc}=    Execute Command    sudo systemctl start tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    Sleep    10s
Check PID of c8y-log-plugin
    ${pid}=    Execute Command    pgrep c8y_log_plugin
    Set Suite Variable    ${pid}
Restart c8y-log-plugin
    ${rc}=    Execute Command    sudo systemctl restart c8y-log-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Recheck PID of c8y-log-plugin
    ${pid1}=    Execute Command    pgrep c8y_log_plugin
    Set Suite Variable    ${pid1}
Compare PID change
    Should Not Be Equal    ${pid}    ${pid1}
Stop watchdog service
    ${rc}=    Execute Command    sudo systemctl stop tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Remove entry from service file
    ${rc}=    Execute Command    sudo sed -i '10d' /lib/systemd/system/c8y-log-plugin.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

 
*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

