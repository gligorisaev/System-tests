*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
#Library    CryptoLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}    crypt:2gqzBhss/4dJeziEoIiNQphS61l6UnbmZXezKZ4bU1KCmUozfrOAEVyeZcO6+nnIb0x6yJnm4dO7Ae2+HBy4
${USERNAME}    crypt:oKtnJPm8I43EUvE1z2dxa87UPoObSxKZ4XuMheZuGiBADPZlppHknIo9evghNvCgf7M=    
${PASSWORD}    crypt:5UGjQfM9NKfGFZOrO6ivMzD4PT6aYHl7e51X8/g0XS8LCmtBK5hBrAYccAlTItE6kbrjnoq8978=  
${DeviceID}       Rpi3lite
${Version}        0.*
${download_dir}    /home/pi/download
${url_dow}     https://github.com/thin-edge/thin-edge.io/actions
${user_git}    crypt:eLyh1H7GqGBR4a+S8GD1BC+2sGyZgZgZffIRqFNOLyuPlZ215jFp+x6vljbPVcLIAezHzIKV0Ll/V+TkncB84A/Y/df1
${pass_git}    crypt:QR6sm+qtIpQyba0W80FYsdXWUi+IFSx00KY2IDMUBnT+okliM8UxL2xtuc17ce3hvs5DUF1N5OB2LqnKWFhJ8w==
${FILENAME}
${DIRECTORY}    /home/pi/download
${url}    crypt:PWwW5fJfxKPsguGoPTgnOQvatZPxHQZNQsxMGcrQvyoNSd/WlBeQInmYA4s3jWJ79hVwg4XRmlSHZ3VEbnNcmlqcJBzxWA4qlj/xCFZGIAa+SrY=
${user}    crypt:/hNeN8ERELHDbpPcT+/iTj0tA+NwZr54jSRGicuejkBFSo9jNk4Bd6lFvVB+f57s1Yi9r44s
${pass}    crypt:mdDKVUZG+4dBZoN9QnGESZ7N+A5Zo1RbDxktuPVQwlvvDPfvIC+/4qFq19d61v+38oj4rXPKNOC0Pg==
${BUILD}
${ARCH}
${dir}

*** Tasks ***
Check Architecture    
    ${output}=    SSHLibrary.Execute Command   uname -m
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
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
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
    Execute Command    chmod a+x uninstall_script.sh
    Execute Command    ./uninstall_script.sh purge

# Remove device from Cumulocity
    New Page    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
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
    Sleep    10s
    Hover    //td[@class='cdk-cell cdk-column-actions']
    Click    (//td[@class='cdk-cell cdk-column-actions'])[1] >> //i[@class='text-danger dlt-c8y-icon-minus-circle']
    Wait For Elements State    //button[@title='Delete']    visible
    Click    //button[@title='Delete']

# Remove certificates from Cumulocity
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Trusted certificates']    visible
    Click    //span[normalize-space()='Trusted certificates']
    Wait For Elements State    //i[@c8yicon='certificate']    visible
    Click    //button[@title='Actions']//i
    Wait For Elements State    //span[normalize-space()='Delete']    visible
    Click    //span[normalize-space()='Delete']
    Wait For Elements State    //button[normalize-space()='Delete']    visible
    Click    //button[normalize-space()='Delete']
    install tedge

install tedge
    SSHLibrary.Execute Command    rm *.deb
    SSHLibrary.Execute Command    rm *.zip
# Download the Package
    New Context    acceptDownloads=True
    New Page    ${url_dow} 
    Click    //a[normalize-space()='Sign in']
    Fill Text    //input[@id='login_field']    ${user_git}
    Fill Text    //input[@id='password']    ${pass_git}
    Click    //input[@name='commit']
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
    Put File    /home/pi/*${FILENAME}.zip
    Execute Command    mv download${FILENAME}.zip ${FILENAME}.zip
# Unpack the File
    SSHLibrary.Execute Command    unzip ${FILENAME}.zip
# Dependency installation
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install mosquitto
# Install Libmosquitto1
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install libmosquitto1
# Install Collectd-core
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install collectd-core
# thin-edge.io installation
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_${Version}_arm*.deb
# Install Tedge mapper
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_mapper_${Version}_arm*.deb
# Install Tedge agent
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_agent_${Version}_arm*.deb
# Install Tedge apama plugin
    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apama_plugin_${Version}_arm*.deb
# Install tedge apt plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apt_plugin_${Version}_arm*.deb
# Install Tedge logfile request plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_log_plugin_${Version}_arm*.deb
# Install C8y plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_configuration_plugin_${Version}_arm*.deb
# Executing Create self-signed certificate
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert create --device-id ${DeviceID}
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Log    ${output}
    #You may notice that the issuer of this certificate is the device itself. This is a self-signed certificate. To use a certificate signed by your Certificate Authority, see the reference guide of tedge cert.
# Configure the device
    SSHLibrary.Execute Command    sudo tedge config set c8y.url gligor.latest.stage.c8y.io    #Set the URL of your Cumulocity IoT tenant
    # SSHLibrary.Execute Command    sudo tedge config set c8y.root.cert.path /etc/ssl/certs     #Set the path to the root certificate if necessary. The default is /etc/ssl/certs.
    #This will set the root certificate path of the Cumulocity IoT. In most of the Linux flavors, the certificate will be present in /etc/ssl/certs.
    Write   sudo tedge cert upload c8y --user gligor
    Write    Ian@240821
    Sleep    3s
    ${output}=    SSHLibrary.Execute Command    sudo tedge connect c8y
    Should Contain    ${output}    tedge-agent service successfully started and enabled!
    SSHLibrary.Execute Command    rm *.deb
    SSHLibrary.Execute Command    rm *.zip
