*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${Version}        0.7.3
${HOST}           192.168.100.110
${USERNAME}       pi
${PASSWORD}       thinedge


*** Tasks ***

Check if installation exists on Device
     ${dir}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge_agent
    Log    ${dir}
    Set Suite Variable    ${dir} 

    Run Keyword If    '${dir}'=='tedge_agent'    Exists
    ...  ELSE    Doesnt exists

Check Architecture    
    ${output}=    SSHLibrary.Execute Command   uname -m
    ${ARCH}    Set Variable    ${output}
    Set Global Variable    ${ARCH}
Set File Name
    Run Keyword If    '${ARCH}'=='aarch64'    aarch64
    ...  ELSE    armv7 



*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}

Exists
    SSHLibrary.Execute Command    sudo tedge disconnect c8y
    SSHLibrary.Execute Command    sudo dpkg -P c8y_configuration_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_agent
    SSHLibrary.Execute Command    sudo dpkg -P c8y_log_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_mapper
    SSHLibrary.Execute Command    sudo dpkg -P tedge_apt_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_apama_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge
    SSHLibrary.Execute Command    sudo dpkg -P mosquitto
    SSHLibrary.Execute Command    sudo dpkg -P libmosquitto1
    SSHLibrary.Execute Command    sudo DEBIAN_FRONTEND=noninteractive dpkg -P collectd-core
    SSHLibrary.Execute Command    sudo apt -y autoremove

Doesnt exists
    SSHLibrary.Execute Command    rm *.deb
    SSHLibrary.Execute Command    rm *.zip

# Copy File to Device
    Put File    /Users/glis/Downloads/${FILENAME}.zip
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
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert create --device-id builder
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Log    ${output}
# Configure the device
    SSHLibrary.Execute Command    sudo tedge config set c8y.url gligor.latest.stage.c8y.io
    Write   sudo tedge cert upload c8y --user gligor
    Write    Ian@240821
    Sleep    3s
    ${output}=    SSHLibrary.Execute Command    sudo tedge connect c8y
    Should Contain    ${output}    tedge-agent service successfully started and enabled!
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