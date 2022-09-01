#Command to execute:    robot -d \results --timestampoutputs --log build-install.html --report NONE --variable BUILD:821 build-install.robot
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
${HOST}           192.168.1.130
${USERNAME}       pi
${PASSWORD}       thinedge
${DeviceID}       
${Version}        0.*
${download_dir}    /Users/glis/Downloads
${url_dow}    https://github.com/thin-edge/thin-edge.io/actions
${user_git}    gligorisaev@gmail.com
${pass_git}    IanIsaev24082021
${FILENAME}
${DIRECTORY}    /Users/glis/Downloads/
${url}    https://thin-edge-io.eu-latest.cumulocity.com/
${url_tedge}    thin-edge-io.eu-latest.cumulocity.com
${user}    systest_preparation
${pass}    Alex@210295
${BUILD}
${ARCH}
${dir}

*** Tasks ***
Create Timestamp
        ${timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${timestamp}
        Set Global Variable    ${timestamp}
Define Device id
        ${DeviceID}   Set Variable    ST${timestamp}
        Set Suite Variable    ${DeviceID}
Check Architecture    
    ${output}=    Execute Command   uname -m
    ${ARCH}    Set Variable    ${output}
    Set Global Variable    ${ARCH}

Set File Name
    Run Keyword If    '${ARCH}'=='aarch64'    aarch64
    ...  ELSE    armv7   

Check if installation exists on Device
     ${dir}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge_agent
    Log    ${dir}
    Set Suite Variable    ${dir} 

    Run Keyword If    '${dir}'=='tedge_agent'    uninstall tedge script
    ...  ELSE    install tedge


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
aarch64
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-aarch64-unknown-linux-gnu
    Log    ${FILENAME}
    Set Global Variable    ${FILENAME}
armv7
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-armv7-unknown-linux-gnueabihf
    Log    ${FILENAME}
    Set Global Variable    ${FILENAME}
uninstall tedge script
    Execute Command    wget https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/uninstall-thin-edge_io.sh
    Execute Command    chmod a+x uninstall-thin-edge_io.sh
    Execute Command    ./uninstall-thin-edge_io.sh purge

#  Remove device from Cumulocity
    New Page    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
    Click    //button[normalize-space()='Agree and proceed']
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@class='icon-2x dlt-c8y-icon-th']    visible
    Click    //i[@class='icon-2x dlt-c8y-icon-th']
    Wait For Elements State    //span[normalize-space()='Device management']    visible
    Click    //span[normalize-space()='Device management']
    Wait For Elements State    //span[normalize-space()='Devices']    visible
    Click    //span[normalize-space()='Devices']
    Wait For Elements State    //span[normalize-space()='All devices']    visible
    Click    //span[normalize-space()='All devices']
    Sleep    2s
    Wait For Elements State    //span[normalize-space()='Management']    visible
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Trusted certificates']    visible
    Click    //span[normalize-space()='Trusted certificates']
    Sleep    5s
    Click    //i[@class='icon-2x dlt-c8y-icon-search']
    Wait For Elements State    //input[@placeholder='Search for groups or assets…']    visible
    Type Text    //input[@placeholder='Search for groups or assets…']    ST
    Wait For Elements State    //button[@title='Starts with']    visible
    Click    //button[@title='Starts with']
    Sleep    5s
    Hover    //td[@class='cdk-cell cdk-column-actions']
    Click    (//td[@class='cdk-cell cdk-column-actions'])[1] >> //i[@class='text-danger dlt-c8y-icon-minus-circle']
    Wait For Elements State    //label[@title='Delete devices']//span[1]    visible
    Click    //label[@title='Delete devices']//span[1]
    Click    //button[normalize-space()='Delete']
    install tedge

install tedge
    Execute Command    rm *.deb | rm *.zip | rm *.sh*

# Download the Package
    New Context    acceptDownloads=True
    New Page    ${url_dow} 
    Click    //a[normalize-space()='Sign in']
    Fill Text    //input[@id='login_field']    ${user_git}
    Fill Text    //input[@id='password']    ${pass_git}
    Click    //input[@name='commit']
    # Pause Execution
    Fill Text    //input[@placeholder='Filter workflow runs']    workflow:build-workflow is:success 
    Keyboard Key    press    Enter   
    Sleep    5s
    Wait For Elements State    //*[contains(@aria-label, '${BUILD}')]    visible
    Click    //*[contains(@aria-label, '${BUILD}')]
    Sleep    5s
    Wait For Elements State     //a[normalize-space()='${FILENAME}']    visible
    ${dl_promise}          Promise To Wait For Download    ${DIRECTORY}${FILENAME}.zip
    Click    //a[normalize-space()='${FILENAME}']
    ${file_obj}=    Wait For  ${dl_promise}
    Sleep    5s

# Copy File to Device
    Put File    /Users/glis/Downloads/${FILENAME}.zip

# Unpack the File
    ${rc}=    Execute Command    unzip ${FILENAME}.zip    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Dependency installation
    ${rc}=    Execute Command    sudo apt-get --assume-yes install mosquitto    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Libmosquitto1
    ${rc}=    Execute Command    sudo apt-get --assume-yes install libmosquitto1    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Collectd-core
    ${rc}=    Execute Command    sudo apt-get --assume-yes install collectd-core    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# thin-edge.io installation
    ${rc}=    Execute Command    sudo dpkg -i ./tedge_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Tedge mapper
    ${rc}=    Execute Command    sudo dpkg -i ./tedge_mapper_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Tedge agent
    ${rc}=    Execute Command    sudo dpkg -i ./tedge_agent_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Tedge apama plugin
    ${rc}=    Execute Command    sudo dpkg -i ./tedge_apama_plugin_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install tedge apt plugin
   ${rc}=    Execute Command    sudo dpkg -i ./tedge_apt_plugin_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Tedge logfile request plugin
   ${rc}=    Execute Command    sudo dpkg -i ./c8y_log_plugin_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install C8y plugin
    ${rc}=    Execute Command    sudo dpkg -i ./c8y_configuration_plugin_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Install Watchdog
    ${rc}=    Execute Command    sudo dpkg -i ./tedge_watchdog_${Version}_arm*.deb    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

# Executing Create self-signed certificate
    ${rc}=    Execute Command    sudo tedge cert create --device-id ${DeviceID}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    ${output}=    Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem

# Configure the device
    ${rc}=    Execute Command    sudo tedge config set c8y.url ${url_tedge}    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}
    
    Write   sudo tedge cert upload c8y --user ${user}
    Write    ${pass}
    Sleep    3s

    ${output}=    Execute Command    sudo tedge connect c8y    #You can then check the content of that certificate.
    Should Contain    ${output}    tedge-agent service successfully started and enabled!

    Execute Command    rm *.deb | rm *.zip | rm *.sh*
