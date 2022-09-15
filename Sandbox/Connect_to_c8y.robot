#Command to execute:    robot -d \results --timestampoutputs --log build_install_rpi.html --report NONE --variable BUILD:840 --variable HOST:192.168.1.130 /thin-edge.io/tests/RobotFramework/tasks/build_install_thinedge.robot
*** Settings ***
Library    Browser
Library    SSHLibrary
Library    DateTime
Library    CryptoLibrary    variable_decryption=True
Library    Dialogs
Library    String
Library    CSVLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.1.130
${USERNAME}       pi
${PASSWORD}       thinedge    #crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=          
${Version}        0.*
${download_dir}    /home/pi/
${url_dow}    https://github.com/thin-edge/thin-edge.io/actions
# ${user_git}    crypt:3Uk76kNdyyYOXxus2GFoLf8eRlt/W77eEkcSiswwh04HNfwt0NlJwI7ATKPABmxKk8K1a8NsI5QH0w8EmT8GWeqrFwX2    
# ${pass_git}    crypt:IcTs6FyNl16ThjeG6lql0zNTsjCAwg5s6PhjRrcEwQ9DVHHRB4TjrGcpblR6R1v7j9oUlL3RzwxGpfBfsijVnQ==    
${url}    https://qaenvironment.eu-latest.cumulocity.com/
${url_tedge}    qaenvironment.eu-latest.cumulocity.com
${user}    qatests
${pass}    Alex@210295    #crypt:34mpoxueRYy/gDerrLeBThQ2wp9F+2cw50XaNyjiGUpK488+1fgEfE6drOEcR+qZQ6dcjIWETukbqLU=    

*** Test Cases ***
    #The very first step to enable `thin-edge.io` is to connect your device to the cloud.
    #This is a 10 minutes operation to be done only once.
    #It establishes a permanent connection from your device to the cloud end-point.
    #This connection is secure (encrypted over TLS), and the two peers are identified by x509 certificates.
    #Sending data to the cloud will then be as simple as sending data locally.
    #Before you try to connect your device to Cumulocity IoT, you need:
    #The url of the endpoint to connect (e.g. `eu-latest.cumulocity.com`). ${url} 
    #Your credentials to connect Cumulocity:
    #Your tenant identifier (e.g. `t00000007`), a user name (${user}) and password (${pass}).
    #None of these credentials will be stored on the device.
    #These are only required once, to register the device.
    #If not done yet, 
Install thin-edge.io on your device
    Create Timestamp
    Define Device id
    Uninstall tedge with purge
    Clear previous downloaded files if any
    Install_thin-edge
    #Configure the device
    #To connect the device to the Cumulocity IoT, one needs to set the URL of your Cumulocity IoT tenant and the root certificate as below.
Set the URL of your Cumulocity IoT tenant
    ${rc}=    Execute Command    sudo tedge config set c8y.url ${url_tedge}    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}
# Set the path to the root certificate if necessary. The default is /etc/ssl/certs.
#     ${rc}=    Execute Command    $ sudo tedge config set c8y.root.cert.path /etc/ssl/certs    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
#     Should Be Equal    ${rc}    ${0}
    #This will set the root certificate path of the Cumulocity IoT. In most of the Linux flavors, the certificate will be present in /etc/ssl/certs.
    #A single argument is required: an identifier for the device. 
    #This identifier will be used to uniquely identify your devices among others in your cloud tenant. 
    #This identifier will be also used as the Common Name (CN) of the certificate. 
    #Indeed, this certificate aims to authenticate that this device is actually the device with that identity.
Create the certificate
    ${rc}=    Execute Command    sudo tedge cert create --device-id ${DeviceID}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    #You can then check the content of that certificate.
    ${output}=    Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Should Contain    ${output}    Subject: CN=${DeviceID}, O=Thin Edge, OU=Test Device
    Should Contain    ${output}    Issuer: CN=${DeviceID}, O=Thin Edge, OU=Test Device
    Should Contain    ${output}    Valid from:
    Should Contain    ${output}    Valid up to:
    Should Contain    ${output}    Thumbprint:
    #You may notice that the issuer of this certificate is the device itself. This is a self-signed certificate. 
    #To use a certificate signed by your Certificate Authority, see the reference guide of tedge cert.
    #The tedge cert create command creates a self-signed certificate which can be used for testing purpose.

    #Make the device trusted by Cumulocity
    #For a certificate to be trusted by Cumulocity, one needs to add the certificate of the signing authority to the list of 
    #trusted certificates. In the Cumulocity GUI, navigate to "Device Management/Management/Trusted certificates" in order to 
    #see this list for your Cumulocity tenant. 
    #Here, the device certificate is self-signed and has to be directly trusted by Certificate. This can be done:
    #either with the GUI: upload the certificate from your device (/etc/tedge/device-certs/tedge-certificate.pem) to your 
    #tenant "Device Management/Management/Trusted certificates".
    #or using the 
tedge cert upload c8y command.
    #$ sudo tedge cert upload c8y --user <username>
    #To upload the certificate to cumulocity this user needs to have "Tenant management" admin rights. 
    #If you get an error 503 here, check the appropriate rights in cumulocity user management.
    Write   sudo tedge cert upload c8y --user ${user}
    Write    ${pass}
    Sleep    3s
Connect the device
    #Now, you are ready to run tedge connect c8y. This command configures the MQTT broker:
    #-to establish a permanent and secure connection to the cloud,
    #-to forward local messages to the cloud and vice versa.
    #Also, if you have installed tedge_mapper, this command starts and enables the tedge-mapper-c8y systemd service. 
    #At last, it sends packets to Cumulocity to check the connection. If your device is not yet registered, 
    #you will find the digital-twin created in your tenant after tedge connect c8y!
    ${output}=    Execute Command    sudo tedge connect c8y    #You can then check the content of that certificate.
    Sleep    3s
    Should Contain    ${output}    Checking if systemd is available.
    Should Contain    ${output}    Checking if configuration for requested bridge already exists.
    Should Contain    ${output}    Validating the bridge certificates.
    Should Contain    ${output}    Creating the device in Cumulocity cloud.
    Should Contain    ${output}    Saving configuration for requested bridge.
    Should Contain    ${output}    Restarting mosquitto service.
    Should Contain    ${output}    Awaiting mosquitto to start. This may take up to 5 seconds.
    Should Contain    ${output}    Enabling mosquitto service on reboots.
    Should Contain    ${output}    Successfully created bridge connection!
    Should Contain    ${output}    Sending packets to check connection. This may take up to 2 seconds.
    Should Contain    ${output}    Connection check is successful.
    Should Contain    ${output}    Checking if tedge-mapper is installed.
    Should Contain    ${output}    Starting tedge-mapper-c8y service.
    Should Contain    ${output}    Persisting tedge-mapper-c8y on reboot.
    Should Contain    ${output}    tedge-mapper-c8y service successfully started and enabled!
    Should Contain    ${output}    Enabling software management.
    Should Contain    ${output}    Checking if tedge-agent is installed.
    Should Contain    ${output}    Starting tedge-agent service.
    Should Contain    ${output}    Persisting tedge-agent on reboot.
    Should Contain    ${output}    tedge-agent service successfully started and enabled!

Sending your first telemetry data
    #Sending data to Cumulocity is done using MQTT over topics prefixed with c8y. Any messages sent to one of these topics will be 
    #forwarded to Cumulocity. The messages are expected to have a format specific to each topic. Here, we use tedge mqtt pub a raw 
    #Cumulocity SmartRest message to be understood as a temperature of 20 Celsius.
    ${rc}=    Execute Command    tedge mqtt pub c8y/s/us 211,20    return_stdout=False    return_rc=True    #Set the URL of your Cumulocity IoT tenant
    Should Be Equal    ${rc}    ${0}


Download the measurements report file
    #To check that this message has been received by Cumulocity, navigate to "Device Management/Devices/All devices/<your device id>/Measurements". 
    #You should observe a "temperature measurement" graph with the new data point.
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
    Wait For Elements State    div[ng-class='truncated-cell-content']    visible
    Click    //a[@title='${DeviceID}']
    Wait For Elements State    //span[normalize-space()='Measurements']    visible
    Click    //span[normalize-space()='Measurements']
    Wait For Elements State    //body/c8y-ui-root[@id='app']/c8y-bootstrap/div/div/div/div[@id='c8y-legacy-view']/div[@ng-if='vm.widthSet && vm.authState.hasAuth']/div[@ng-controller='measurementsCtrl as ctrl']/c8y-list-pagination[@items='supportedMeasurements']/div/div/c8y-measurements-fragment-chart[@fragment='m']/div/div/c8y-chart[@datapoints='vm.dataPoints']/div[2]//*[name()='svg'][1]/*[name()='rect'][1]
    Click    //span[contains(text(),'More…')]
    Click    (//button[@title='Download as CSV'][normalize-space()='Download as CSV'])[2]
    Wait For Elements State    //a[normalize-space()='Download']    visible
    ${dl_promise}          Promise To Wait For Download    ${download_dir}report.zip
    Click    //a[normalize-space()='Download']
    ${file_obj}=    Wait For  ${dl_promise}
    Sleep    5s

# Copy the downloaded report
#     ${rc}=    Execute Command    Put File ${download_dir}report.zip    return_stdout=False    return_rc=True
#     Should Be Equal    ${rc}    ${0}

   
Unzip the report
    ${rc}=    Execute Command    unzip report.zip    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}


Delete the zip file
    Execute Command    rm *.zip

Get the report file name
    ${report}=    Execute Command    ls
    Set Suite Variable    ${report}

Read csv file to a list example test
    @{list}=  Read Csv File To List    ${download_dir}${report}
    Log  ${list[0]}
    Log  ${list[1]}




*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
Create Timestamp    #Creating timestamp to be used for Device ID
        ${timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${timestamp}
        Set Global Variable    ${timestamp}
Define Device id    #Defining the Device ID, structure is (ST'timestamp') (eg. ST01092022091654)
        ${DeviceID}   Set Variable    ST${timestamp}
        Set Suite Variable    ${DeviceID}
Uninstall tedge with purge
    Execute Command    wget https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/uninstall-thin-edge_io.sh
    Execute Command    chmod a+x uninstall-thin-edge_io.sh
    Execute Command    ./uninstall-thin-edge_io.sh purge
Clear previous downloaded files if any
    Execute Command    rm *.deb | rm *.zip | rm *.sh*
Install_thin-edge
    ${rc}=    Execute Command    curl -fsSL https://raw.githubusercontent.com/thin-edge/thin-edge.io/main/get-thin-edge_io.sh | sudo sh -s    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
