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
# Encrupted text can be replaced and own data can be used
${HOST}           crypt:TtXFX2OzHrCxbTIt5ThoaWVK+uT3YNNVwgrOobWapAi2IDkY/kn3mNQsZ2digMHHri3LQqKCgqQ2vdkEtmab
${USERNAME}       crypt:gseg6/kuH7TzEy2xbJx/sc8+Srzn+jmJC4w9qmZkyR3jTxyJ/FY2mPgZ7rmAneFnL5s=
${PASSWORD}       crypt:Ed80ER5yXWDKXYfcHr7T4vAkcc5IsPMYpppnhPwDUCWjSg68KT4fhU5RMY1AYyrrDJNoO5e4LEk=
${url}            crypt:ZyyuglOwEIYlRfDpDpZOoyOhEfK4tKrRDjwHbDJ1nDmPgR4nNJKxzJ7K2dDYbyfVn7PmFalyQcrtDkzBVo1vpgFjp8V0gHZGrTDl34O131a3PLw=
${user}		  crypt:cDcuVrWp9b21QRDMlFaEFTaGQpjDXKrd8xXVCJwucRabEGGP7GyDRl++LNaqMTV0SQjzn+8F
${pass}		  crypt:Wvh7XkX6Q9aVxYOr5xCpsmrC+WhrX8jdvLdFnQOsrw9Y4jyd1tPxpaFoSlrQcV7T/b2ngJlSk9NWAg==
${url_dow}        crypt:sWkHIPQPWer/uJpWUtS8Qo14ECt+QnABqR7Eptae3hSPhUMM3SzkV4BNHSR0S5ukgGzWD+j/eVRWP2aP455e7rwsiJQ1CH1hktZ76afOj7v1VvAr5Mp99vNWQTvga5IFXg==
${user_git}       crypt:IY5AaLe0t9COJtMHU3cZXyB7GTW93bjdlTGMYnr8PEo20z+5eDwQciOeIP998as6JxYvY3cZR6nHxbd1i17bV+ptM97+
${pass_git}       crypt:UjT5CYmOJeA0yUiU24Fbe+UEG4+QFOEetwvue+aAFyDixQQbdWoN+hJXwoiNC20RWxzd6uS+LUGZUsxwBNeHYA==

${DeviceID}       RPI Test
${Version}        0.*

${FILENAME}
${DIRECTORY}    /home/pi/download

${BUILD}
${ARCH}
${dir}


*** Tasks ***
# Create Timestamp
#         ${DeviceID}=    get current date    result_format=%d%m%Y%H%M%S
#         log    ${DeviceID}
#         Set Global Variable    ${DeviceID}
Check Architecture    
    [Documentation]    Checking the architecture of the DUT and setting it as variable
    ${output}=    SSHLibrary.Execute Command   uname -m
    ${ARCH}    Set Variable    ${output}
    Set Global Variable    ${ARCH}

Set File Name
    [Documentation]    Setting the file name that needs to be downloaded
    Run Keyword If    '${ARCH}'=='aarch64'    aarch64
    ...  ELSE    armv7   

Check if installation exists on Device
    [Documentation]    Checking if installation exists and defining if before new
    ...                installation deinstallation is needed
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
    Execute Command    wget https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/uninstall-thin-edge_io.sh
    Execute Command    chmod a+x uninstall-thin-edge_io.sh
    Execute Command    ./uninstall-thin-edge_io.sh purge

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
    Execute Command    rm *.deb
    Execute Command    rm *.zip
    Execute Command    rm *.sh
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
