#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Anti-Virus utilities... "
  yum -y install amavisd-new spamassassin clamav clamav-server clamav-server-systemd clamav-data-empty clamav-update clamav-unofficial-sigs postgrey unzip bzip2 unrar perl-DBD-mysql > /dev/null 2>&1
  sed -i "s/Example/#Example/" /etc/freshclam.conf
  sa-update
  freshclam 
  systemctl enable amavisd.service
  echo -e "${green}done! ${NC}\n"
}
