*** Settings ***
Documentation    Purpose of this test is to verify that configuring alternate download path 
...              and triggering a software installation with a custom binary  

Library    SSHLibrary
Library    Browser
Library    CryptoLibrary    variable_decryption=True
Library    Dialogs

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections


*** Variables ***
${HOST}           192.168.0.37    #Insert the IP address if the default should not be used
${USERNAME}       crypt:v/xPnyEmjvBm9W/wY+dBC8zF/PNDJTGkuQE7s8/W/zTGjb1ONn70YpIXblngo00VJ9E=    #Insert the username if the default should not be used
${PASSWORD}       crypt:Lqjbi1ivrpopGxIaKPHPWlW+gLykaMCSa/tRiMl0GFA38d4nIDe9e4TYl5dQHZAhIGdzkOA3TBUKHA==    #Insert the password if the default should not be used
${url}    crypt:RUB5oFkTpQm1P2IH2Uga/CORs1Wma/hhPgPrtUMklkkCCpUulEb3+pKp91oSibwp86pj3Kh4wYN9zinQo4eRnf77DERT39O3XpUF9qbSfqM/2pE=
${user}    crypt:6REAYgP+D2HrE7rs0MY+RLhxkyA7/swn6Q31nzlg8XAH5vcVgB8UDtY4bpm0EXN6WycPMlcK
${pass}    crypt:aeG7zyiCTtDArXg+hSh9zIbEWU4lgrekbtn54XbNTluIlEzT44gQAmcuh92Txvumh6Sg+3Ac05hDcw==


*** Tasks ***
C8Y
    Open Browser    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']

    Pause Execution
    
*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}