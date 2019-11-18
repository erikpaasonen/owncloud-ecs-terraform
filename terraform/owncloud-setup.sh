sudo mv owncloud.conf /etc/apache2/sites-available/owncloud.conf
sudo ln -s /etc/apache2/sites-available/owncloud.conf /etc/apache2/sites-enabled/owncloud.conf
wget https://download.owncloud.org/owncloud.asc
gpg --import owncloud.asc
wget https://download.owncloud.org/community/owncloud-${local.owncloud_version}.zip
wget https://download.owncloud.org/community/owncloud-${local.owncloud_version}.zip.sha256
gpg --verify owncloud-${local.owncloud_version}.zip owncloud-${local.owncloud_version}.zip.sha256
sha256sum -c owncloud-${local.owncloud_version}.zip.sha256 < owncloud-${local.owncloud_version}.zip
unzip owncloud-${local.owncloud_version}.zip
sudo cp -r owncloud /var/www
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime
sudo a2enmod unique_id
sudo systemctl restart apache2
