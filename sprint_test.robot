*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections


*** Variables ***
${HOST}           crypt:zl4vjWn8YTpt1b7nPF8J/XeQ82z/M+rjRjpXD5zXdE25PYB3BmXUY4fq/VuO5LrY6eDgMiAd2JKOei56RWMR
${USERNAME}       pi
${PASSWORD}       crypt:jXjF1xOnsMO5iCan2D1C16blhhf5fB4PrfG7+oY1JD40m7MRz733n/FO1JXz8rgzZsTPrt2/+cs=
${DeviceID}       Rpi3lite
${Version}        0.*
${download_dir}    /home/pi
${url_dow}    crypt:6H+zoJ4YVlWeN5YbHlbzLLw+GfGQ6bkHldbyT5dwLknffPQUAa4bVwVtfdZ2C5K3RwSIBSZFd0j1poWxOOBA08BqIOslfrCVA3GROGpqHsawZpGmdsltkKlVtjrCBwQA4w==
${user_git}    crypt:euPzi2taX01dK1JsLHTfjDQczz84X8wSKL4FC4wagSrXtMoJS/sHN70UtxVvE1NwZYsMOgPTSGEcnLsN25hCGNSEH11l
${pass_git}    crypt:NuvwclAobHmeyt+2cIAz4fUPgYjg3XSZPGsb4ZRqSnApD3uBrppwDIcYjSwRj7g+FgW85SLMUJB2nAWg5M9nMA==
${FILENAME}
${DIRECTORY}    /home/pi
${url}    crypt:8s3iqcoGBY8WNeZsG60uLmurqcZmY3y4QDQnKQWgWxtWDpjNs56ehMhwLDsoFiYdH9++lUsOeyiNZZWBn0mdBJrkdXOzSN6+wudDWD0nRBki40Y=
${user}    crypt:jZ+5ClRKss/QrXzkdzv2Xc3k89TrMAaYvV2vtgNfDDUU6xb5238LMgwmsHw2Bp4c4OEUrrHF
${pass}    crypt:AIgBTujbjDIIYR/GkAh5tEFXPzAhCUxzDSXAJaFoBDvkfvFFeks1GFqP0BCQsSunNGkJ+psJ6kqhhQ==
${BUILD}
${ARCH}
${Timestamp}
${dir}

*** Tasks ***
Get build
    ${BUILD}    Get Value From User    Insert Workflow Number (e.g. 716)
    Log    ${BUILD}
    Set Global Variable    ${BUILD}





*** Keywords ***
Create Timestamp
        ${Timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${Timestamp}
        Set Global Variable    ${Timestamp}
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
