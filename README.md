# laravel-docker

A simple docker environment for a laravel or a simple php application.

This configuration is using the following images from [DockerHub](https://hub.docker.com/):
* __PHP__: php:8.0-fpm (including xDebug)
* __Webserver__: nginx:latest
* __Database__: mariadb:10.5.8
* __Cache__: redis
* __Email__: mailhog

You can customize all the versions and packages in the *docker-compose.yaml* file, or in the */images/*.

## Install
1. __Install__ [docker](https://docs.docker.com/install/)

2. __Clone__ _laravel-docker_ into your project directory:
   ```
   git clone https://github.com/murcoder/laravel-docker.git
   ```

3. __Domain:__ Add the DNS to your */hosts* file
   ```
   127.0.0.1 dev.my-application.com
   ```
   
4. __SSL:__ Create and register a self signed SSL certificate (see chapter SSL below for more informations)


5. __Environment:__ Copy content of _.env.development_ to your local _.env_ file


7. __Start:__ Build and start the docker containers in your docker directory
   ```
   docker-compose up -d
   ```

8. __DONE!__ open https://dev.my-application.com/

<br>

## How to work
__Into the app container__: Get in your app container and install composer packages for instance
```
docker-compose exec app bash
cd /var/www/
composer install
```

<br>


## Useful commands
```
# create and start containers without logging
docker-compose up -d
 
# create and start containers with log
docker-compose up
 
# stop and remove containers, networks, images, and volumes
docker-compose down
 
# step into the php container
docker-compose exec app bash
 
# step into the mysql container
docker-compose exec mysql bash
 
# list containers
docker-compose ps
 
# remove unused data
docker system prune
```

<br>

## DB

_jdbc:mariadb://localhost:8001/my_app_db_
```
HOST=db
PORT=3306
DATABASE=my_app_db
USERNAME=root
PASSWORD=root
```

### Laravel
 Create the __.env__ file in your root project directory and add the database settings:
```
DB_CONNECTION=mysql #defined in /app/config/database.php
DB_HOST=db
DB_PORT=3306
DB_DATABASE=my_app_db
DB_USERNAME=root
DB_PASSWORD=root
```

<br>

## SSL
Create a self-signed certificate for using https on localhost.

### Create Certificate Authority
To sign your own certificate, you need your own certification authority.

1. Create private key and set password (needed later)
   ```
   openssl genrsa -des3 -out myCertificationAuthority.key 2048
   ```

2. Create root certificate and set common_name=dev.my-application.com (let other fields empty)
   ```
   openssl req -x509 -new -nodes -key myCertificationAuthority.key -sha256 -days 825 -out myCertificationAuthority.pem
   ```
   
### Register in Browser
**Chrome:** Settings/Security/Certificates verwalten

**Firefox:** Settings/Security/ZertifikateCertificates/Import


### Create Self Signed Key
1. Create key
    ```
   openssl genrsa -out my_application.key 2048
    ```

2. Create Certificate Signing Requests (CSR)
    ```
   openssl req -new -key my_application.key -out my_application.csr -subj '/CN=myCertificationAuthority/O=myCertificationAuthority/OU=IT' -extensions SAN -reqexts SAN -config <( \
   printf "[SAN]\nsubjectAltName=DNS:dev.my-application.com
   \n[dn]\nCN=myCertificationAuthority\n[req]\ndistinguished_name = dn\n[EXT]\nauthorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nsubjectAltName=DNS:dev.my-application.com
   \nkeyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\nextendedKeyUsage=serverAuth")
    ```

3. Create file my_application.ext and insert the following content
    ```
   authorityKeyIdentifier=keyid,issuer
   basicConstraints=CA:FALSE
   keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
   subjectAltName = @alt_names
   [alt_names]
   DNS.1 = dev.my-application.com
    ```

4. Create key by using the self created certificate authority
    ```
   openssl x509 -req -in my_application.csr -out my_application.crt -CA myCertificationAuthority.pem -CAkey myCertificationAuthority.key -CAcreateserial \
   -sha256 -days 3650 \
   -extfile my_application.ext
    ```
   

### Debugging
For debugging xdebug has been already installed in _app.dockerfile_. To use it in PHPstorm:

1. __Phpstorm Port:__ Set Port 9003 in _Phpstorm/Preferences/PHP/Debug_

2. __Phpstorm Path config:__ _Phpstorm/Run/EditConfiguration/PHP Web Page/xdebug_.
   * Add configuration
   * Domain = https://dev.my-application.com
   * Port = 443
   * Use path mapping: /path/to/application => /var/www/





Browser Plugin
Install browser extension and activate:

Chrome: https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=de
Firefox: https://addons.mozilla.org/de/firefox/addon/xdebug-helper-for-firefox/
