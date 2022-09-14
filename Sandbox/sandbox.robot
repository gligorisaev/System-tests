#Command to execute:    robot -d \results --timestampoutputs --log health_tedge_mapper.html --report NONE health_tedge_mapper.robot

*** Settings ***
Library    SSHLibrary 
Library    MQTTLibrary
Library    String
Library    CSVLibrary
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections

*** Variables ***
${HOST}           192.168.1.130
${USERNAME}       pi
${PASSWORD}       thinedge

${path_file}    /home/pi/


*** Tasks ***
Read csv file to a list example test
#   @{list}=  Read Csv File To List    /Users/glis/Downloads/*.csv
  @{list}=  Read Csv File To List    ${path_file}/3203.c8y_TemperatureMeasurement.csv.csv
  Log  ${list[0]}
  Log  ${list[1]}

# Read CSV file
#     # ${rc}=    Execute Command    unzip report.zip    return_stdout=False    return_rc=True
#     # Should Be Equal    ${rc}    ${0}
#     ${csv}=    Get File    /home/pi/3203.c8y_TemperatureMeasurement.csv
#     @{read}=    Create List    ${csv}
#     @{lines}=    Split To Lines    @{read}    1


*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

