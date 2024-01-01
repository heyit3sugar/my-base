#!/bin/bash

# Check for root privileges
if [[ "$(id -u)" != "0" ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Stop on errors
set -e

# Update & Upgrade System
sudo apt update && sudo apt upgrade -y

# Create main folders with -p option
mkdir -p base targets all-nuclei
mkdir -p /base/tools /base/wordlists /base/configs-resolvers
mkdir -p /base/wordlists/assetnote


# Install go Lang if not already installed
if ! command -v go &> /dev/null; then
    sudo snap install go --classic
    # Add the Path
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && source ~/.bashrc
fi

# Install Language's Packages
declare -a packages=("python" "python3" "python3-pip" "ruby" "rustc" "cargo")

for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "$package"; then
        sudo apt install -y "$package"
    else
        echo "$package already installed."
    fi
done

# Install needed packages & tools
sudo apt install metasploit-framework
sudo apt install exploitdb
sudo apt install sqlmap
sudo apt install nmap
sudo apt install -y libpcap-dev git make gcc
git clone https://github.com/danielmiessler/SecLists.git /base/wordlists/seclists
git clone https://github.com/maurosoria/dirsearch.git /base/tools/dirsearch
curl -sL https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -o /base/configs-resolvers/resolvers.txt

# Install More Wordlists
wget -O /base/wordlists/assetnote/httparchive_apiroutes.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_aspx_asp_cfm_svc_ashx_asmx.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_aspx_asp_cfm_svc_ashx_asmx_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_cgi_pl.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_cgi_pl_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_directories.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_directories_1m_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_html_htm.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_html_htm_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_js.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_js_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_jsp_jspa_do_action.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_jsp_jspa_do_action_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_parameters_top_1m.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_parameters_top_1m_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_php.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_php_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_subdomains.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_txt.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_txt_2023_12_28.txt
wget -O /base/wordlists/assetnote/httparchive_xml.txt https://wordlists-cdn.assetnote.io/data/automated/httparchive_xml_2023_12_28.txt
wget -O /base/wordlists/assetnote/swagger-wordlist.txt https://wordlists-cdn.assetnote.io/data/kiterunner/swagger-wordlist.txt
wget -O /base/wordlists/assetnote/adobe.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_adobe_experience_manager_2023_12_28.txt
wget -O /base/wordlists/assetnote/django.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_django_2023_12_28.txt
wget -O /base/wordlists/assetnote/express.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_express_2023_12_28.txt
wget -O /base/wordlists/assetnote/flask.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_flask_2023_12_28.txt
wget -O /base/wordlists/assetnote/laravel.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_laravel_2023_12_28.txt
wget -O /base/wordlists/assetnote/nginx.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_nginx_2023_12_28.txt
wget -O /base/wordlists/assetnote/symfony.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_symfony_2023_12_28.txt
wget -O /base/wordlists/assetnote/tomcat.txt https://wordlists-cdn.assetnote.io/data/technologies/httparchive_tomcat_2023_12_28.txt
wget -O /base/wordlists/assetnote/2m-subdomains.txt https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt
wget -O /base/wordlists/assetnote/asp_lowercase.txt https://wordlists-cdn.assetnote.io/data/manual/asp_lowercase.txt
wget -O /base/wordlists/assetnote/aspx_lowercase.txt https://wordlists-cdn.assetnote.io/data/manual/aspx_lowercase.txt
wget -O /base/wordlists/assetnote/best-dns-wordlist.txt https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget -O /base/wordlists/assetnote/html.txt https://wordlists-cdn.assetnote.io/data/manual/html.txt
wget -O /base/wordlists/assetnote/jsp.txt https://wordlists-cdn.assetnote.io/data/manual/jsp.txt
wget -O /base/wordlists/assetnote/php.txt https://wordlists-cdn.assetnote.io/data/manual/php.txt
wget -O /base/wordlists/assetnote/phpmillion.txt https://wordlists-cdn.assetnote.io/data/manual/phpmillion.txt

# Clone and install masscan
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make && sudo make install
sudo cp bin/masscan /usr/local/bin
echo "masscan installed successfully."
cd ..
rm -rf masscan

# Install MY-Go-Tools
GO111MODULE=on go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
~/go/bin/pdtm -ia

GO111MODULE=on go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
GO111MODULE=on go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
GO111MODULE=on go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest
GO111MODULE=on go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest
GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
GO111MODULE=on go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
GO111MODULE=on go install -v github.com/projectdiscovery/katana/cmd/katana@latest
GO111MODULE=on go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
GO111MODULE=on go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest
GO111MODULE=on go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest

# Nuclei Setup
GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
GO111MODULE=on go install -v github.com/xm1k3/cent@latest
git clone https://github.com/projectdiscovery/nuclei-templates.git
cd all-nuclei
~/go/bin/cent init
~/go/bin/cen -p cent-nuclei-templates
git clone https://github.com/projectdiscovery/fuzzing-templates.git
cd -

# Tomnomnom
GO111MODULE=on go install -v github.com/tomnomnom/assetfinder@latest
GO111MODULE=on go install -v github.com/tomnomnom/gron@latest
GO111MODULE=on go install -v github.com/tomnomnom/httprobe@latest
GO111MODULE=on go install -v github.com/tomnomnom/unfurl@latest
GO111MODULE=on go install -v github.com/tomnomnom/waybackurls@latest
GO111MODULE=on go install -v github.com/tomnomnom/anew@latest
GO111MODULE=on go install -v github.com/tomnomnom/qsreplace@latest
GO111MODULE=on go install -v github.com/tomnomnom/meg@latest

# gf
GO111MODULE=on go install -v github.com/tomnomnom/gf@latest
GO111MODULE=on go install -v github.com/dwisiswant0/gfx@latest
git clone https://github.com/emadshanab/Gf-Patterns-Collection.git
cd Gf-Patterns-Collection
chmod +x set-all.sh
sudo ./set-all.sh
cd ..

# Other needed tools:
GO111MODULE=on go install -v github.com/ffuf/ffuf@latest
GO111MODULE=on go install -v github.com/d3mondev/puredns/v2@latest
GO111MODULE=on go install -v github.com/OWASP/Amass/v3@latest
GO111MODULE=on go install -v github.com/GerbenJavado/LinkFinder@latest

# Move the Binary data to /usr/local/bin
sudo cp ~/go/bin/* /usr/local/bin/