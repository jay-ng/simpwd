# simpwd, Simple Password Manager
A simple app to test the uses of cryptography, and cyber security knowledges.  

The app contains a local login system, a table view to display information, and a database model to store information. The model is encrypted using Apple Hardware Encryption capability provided for Apple Devices.  

Each user can create an account, with a master password which will be hashed with SHA-256, and each site/login combination is encrypted using AES-256 with the master password hash and a random generated IV associated with each account.
## Prerequisites
Apple machine capable of running xcode 8+, and xcode itself
## Installing
1. Clone/Fork the project
2. Open and build the project
## Author
Huy Nguyen
