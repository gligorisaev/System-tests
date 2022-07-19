*** Settings ***
Documentation    

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



*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}