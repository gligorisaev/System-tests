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
${HOST}           crypt:TtXFX2OzHrCxbTIt5ThoaWVK+uT3YNNVwgrOobWapAi2IDkY/kn3mNQsZ2digMHHri3LQqKCgqQ2vdkEtmab
${USERNAME}       crypt:gseg6/kuH7TzEy2xbJx/sc8+Srzn+jmJC4w9qmZkyR3jTxyJ/FY2mPgZ7rmAneFnL5s=
${PASSWORD}       crypt:Ed80ER5yXWDKXYfcHr7T4vAkcc5IsPMYpppnhPwDUCWjSg68KT4fhU5RMY1AYyrrDJNoO5e4LEk=
${url}            crypt:ZyyuglOwEIYlRfDpDpZOoyOhEfK4tKrRDjwHbDJ1nDmPgR4nNJKxzJ7K2dDYbyfVn7PmFalyQcrtDkzBVo1vpgFjp8V0gHZGrTDl34O131a3PLw=
${user}           crypt:cDcuVrWp9b21QRDMlFaEFTaGQpjDXKrd8xXVCJwucRabEGGP7GyDRl++LNaqMTV0SQjzn+8F
${pass}           crypt:Wvh7XkX6Q9aVxYOr5xCpsmrC+WhrX8jdvLdFnQOsrw9Y4jyd1tPxpaFoSlrQcV7T/b2ngJlSk9NWAg==
${url_dow}        crypt:sWkHIPQPWer/uJpWUtS8Qo14ECt+QnABqR7Eptae3hSPhUMM3SzkV4BNHSR0S5ukgGzWD+j/eVRWP2aP455e7rwsiJQ1CH1hktZ76afOj7v1VvAr5Mp99>
${user_git}       crypt:IY5AaLe0t9COJtMHU3cZXyB7GTW93bjdlTGMYnr8PEo20z+5eDwQciOeIP998as6JxYvY3cZR6nHxbd1i17bV+ptM97+
${pass_git}       crypt:UjT5CYmOJeA0yUiU24Fbe+UEG4+QFOEetwvue+aAFyDixQQbdWoN+hJXwoiNC20RWxzd6uS+LUGZUsxwBNeHYA==


*** Tasks ***
Create download folder on Documentation
    Execute Command    mkdir downloads

*** Keywords ***
Open Connection And Log In

    SSHLibrary.Open Connection     ${HOST}
    SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
