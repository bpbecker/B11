Running the API:
config\application.xml has an important parameter that defines how the API should be executed:
    <API_Hosts>inSitu</API_Hosts> means: load into MiServer-WS and run in the same APL-Session. Disadvantage: one crash will affect all sessions (=users)! Advantage: debugging might be easier, less load on the machone.
    <API_Hosts>::1</API_Hosts> = spawn sep. APL-Processes per session.

Dyalog-Internal:
- some files have comments [*Question*] or [*ToDo*] in them. Pls. ignore the todos and feel free to comment on the questions ;-)
All of that will be deleted before these files are made available for the workshop-attendees.

URLs:
http://localhost:8080/index?fakeit=1  
to access the main-screen (for User=1) without being logged on. Useful in dev (to access the page while login is not functional) - will be erase before distributing.
http://localhost:8080/index
will recognize that you are not logged in and redirect you to 
http://localhost:8080/login
the page to login or signup (both not yet implemented)

API_Link.dws
Bootstrap-ws to setup the environment for running the API-Process. There (and in other .dyalog-files, too), I do rely on ?SE.SALT/Dyalog-fns for ?N-Functionality (which I wanted to avoid because of compatibility with V14). However, is that a safe bet, considering that it might be executed by an RT-Environment, perhaps on Linux? (I also wanted to avoid loading the complete Files.dyalog in order to keep things small).