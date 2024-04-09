
# opnsense_wireguard
A simple script to quickly create and add a wireguard client using the OPNsense wireguard API. 

## Why did I make this?

 - I wanted something simple quick and with no hassle.
 - A way to quickly deploy wireguard clients without the need
   to manually create them in the webgui.
 - And to experiment further with the wireguard API.
 - Keep in mind that you can edit this however you want and make your
   own version out of it, infact this is meant to also be a baseline for
   using the wireguard API for OPNsense.

## Requirements: 
jq to be installed. <br>
You can check if you have it installed by running: <br>
`jq --version` <br>
If you don't have it installed : <br>
For debian based distros: <br>
`Run sudo apt install jq` <br>
For fedora: <br>
`sudo dnf install jq` <br>
For OpenSUSE: <br>
`sudo zypper install jq` <br>
For anything else please refer to your distributions package manager on how to install it. 

## Get your OPNsense API key
In your web gui go into **System > Access > Users**. <br>
Under API keys, generate one and save the key and secret somewhere safe. <br>
You will need it to interact with the opnsense API. </p>

## Usage: 
### Clone the repo: 
`git clone https://github.com/kocey131/opnsense_wireguard` <br>
`cd opnsense_wireguard` 

### Open wg.sh With the code editor of your choice: 
 Paste in your API key and secret. <br>
Next up edit the wg client configuration by adding the ip:port of your wireguard server in the "endpoint" section, (Default port should be 51820). <br>
Everything else can be left as default. </p>

### make it executable: 
`chmod +x wg.sh`
### start the script: 
`./wg.sh`

The script will then prompt you for information regarding the client/server.

That's it.

