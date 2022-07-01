*** Settings ***
Documentation    

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



*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}