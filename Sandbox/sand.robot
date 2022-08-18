*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           crypt:UTvdFc2BthBZqskTyFo0+lpSXtqgm+AxbdgwCMV2wzV8RwRKqtt5gdQp1hP0D7zXjhs03Czh5DmToPAKvoYJ   #Insert the IP address if the default should not be used
${USERNAME}       crypt:sDmxL5W+P1TtlzM82uuqEhvJg33QRy23KWYWdaOiZ2WldGDqehy8gJO/0M7YnO8694I=    #Insert the username if the default should not be used
${PASSWORD}       crypt:yApYmGwr4QLmU7pb6O25xgLLnIM2e9LLt3l7ReJYHXhtDaiC76IhFuEf30WRz2IgMTuOgZQRz+8=    #Insert the password if the default should not be used


*** Tasks ***
Create download folder on Documentation
    Execute Command    mkdir downloads

*** Keywords ***
Open Connection And Log In
   
    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
