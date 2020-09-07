# remotemouse

Simple experiment playing around with some concepts I learned in my Networks class abroad. The goal of this project is to use a phone to remotely control the mouse and keyboard on a laptop.

The project consists of three components:
1. A desktop client which creates a TCP server and listens for incoming connections
2. An iOS app which creates a TCP client and sends instructions to the desktop client. Allows the user to...
   - Search for open servers, and automatically connect to the last used server if it's still open
   - Move the mouse, click, and scroll using the screen as a trackpad
   - Type and access function keys via dedicated buttons at the bottom of the screen
3. A static server hosted on AWS, used to persist and display information about the desktop clients available
