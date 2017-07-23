#!/usr/bin/env sh

# Replace $1 with $2 in $3
replaceInFile() {
    sed -i "s@${1}@${2}@g" ${3}
}

# setup folder
mkdir -p ${AMPACHE_WEB_DIR}
echo "=> Unzip ampache archive"
unzip -q /ampache-${AMPACHE_VER}_all.zip -d ${AMPACHE_WEB_DIR}
mkdir -p /var/log/ampache/ && chown -R ${APACHE_USER}:${APACHE_GROUP} /var/log/ampache/

# Fill all the parameters in the files
fillParameters() {
    # AMPACHE_WEB_DIR
    replaceInFile "\@AMPACHE_WEB_DIR\@" "${AMPACHE_WEB_DIR}" $1
}

# setup parameters in the files
fillParameters "/etc/apache2/conf.d/*.conf"

# Add cron update catalog script
# "/var/lock/ampache" is the mutex directory for update script
mkdir -p /var/lock/ampache && chown -R ${APACHE_USER}:${APACHE_GROUP} /var/lock/ampache
(crontab -l ; echo "0 3 * * * su -s /bin/sh ${APACHE_USER} -c \"/scripts/catalog_update.sh\"")| crontab -

# ampache.cfg.php.dist configuration
# local_web_path
#   if not set, subsonic won't function from local ip
sed -i "s/;local_web_path/local_web_path/g" ${AMPACHE_WEB_DIR}/config/ampache.cfg.php.dist

# waveform
sed -i "s/;waveform = \"false\"/waveform = \"true\"/g" ${AMPACHE_WEB_DIR}/config/ampache.cfg.php.dist

# tmp_dir_path
sed -i "s/;tmp_dir_path = \"false\"/tmp_dir_path = \"\/tmp\/ampache\"/g" ${AMPACHE_WEB_DIR}/config/ampache.cfg.php.dist

# debug
# path
sed -i "s/;log_path/log_path/g" ${AMPACHE_WEB_DIR}/config/ampache.cfg.php.dist

# set correct permissions
chown -R ${APACHE_USER}:${APACHE_GROUP} ${AMPACHE_WEB_DIR}
