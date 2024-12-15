# Parallel Apps In AWS With Docker

## Prerequisites
- Angular
- Node
- Python
- Docker
- Docker-Compose
- AWS Account


## Project is configured to handle and re-route HTTP (Port 80) and HTTPS (Port 443)

Cloudflare redirects all traffic HTTP & HTTPS of flask.example.com and angular.example.com to the EC2 Instance.
The Reverse-Proxy then directs the traffic to appropiate containers


## Cloudflare Domain DNS Records

Under Cloudflare domain DNS Records, the following entries should been added:

| Type | Name        | Content                             | Proxy Status | TTL  |
|------|-------------|-------------------------------------|--------------|------|
| A    | flask       | public ipv4 Address of EC2 Instance | DNS Only     | Auto |
| A    | angular     | public ipv4 Address of EC2 Instance | DNS Only     | Auto |


## Refer to the respective Dockerfile and nginx.conf files

You can obtain the SSL certificate and key from Cloudflare.

## Folder Structure
There is a ssl folder added under Backend, Frontend, Reverse-Proxy which contails the origin.pem (certificate) and origin.key (key)

## Transfer Your Docker Project Image to EC2 Instance

### Local Machine:

#### Build The Images
```sh
$ docker build -t flask_app Backend/myflaskapp
$ docker build -t angular_app Frontend/sample-frontend
$ docker build -t reverse-proxy Reverse-Proxy
```

#### Tag The Images
```sh
$ docker tag flask_app docker_hub_user_name/flask_app:latest
$ docker tag angular_app docker_hub_user_name/angular_app:latest
$ docker tag reverse-proxy docker_hub_user_name/reverse-proxy:latest
```

#### Push The Images From Local System To Docker Hub
```sh
$ docker push docker_hub_user_name/flask_app:latest
$ docker push docker_hub_user_name/angular_app:latest
$ docker push docker_hub_user_name/reverse-proxy:latest
```


## Creating an AWS EC2 Instance

### Steps:

1. Save the private key (.pem file) locally when creating the EC2 instance to SSH into it.
    - Private Key Name: `demo_key_pair`
    - EC2 Instance Name: `demo_instance`

2. Ensure the keys are read-writable only by you:
    ```sh
    $ chmod 600 /path_to_your_keys/EC2_Keys
    ```
    Alternatively, make them only readable by you:
    ```sh
    $ chmod 400 /path_to_your_keys/EC2_Keys
    ```

3. Default usernames are determined by the AMI used (e.g., `ubuntu` for Ubuntu AMI).

4. Connect to the instance:
    ```sh
    $ ssh -i /path_to_your_keys/EC2_Keys/demo_key_pair.pem instance-user-name@instance-public-dns-name
    ```

5. Install Docker on the EC2 Instance:
    ```sh
    $ sudo apt update
    $ sudo apt install -y docker.io
    $ sudo systemctl start docker
    $ sudo systemctl enable docker
    $ sudo usermod -aG docker $USER
    $ docker --version
    ```

6. Install Docker Compose (Optional but recommended):
    ```sh
    $ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $ sudo chmod +x /usr/local/bin/docker-compose
    $ docker-compose --version
    ```

## Install Let's Certify Certbot

### 1. Create Docker Network
```sh
$ docker network create nginx-certbot-network
```

### 2. Create Nginx Configuration for Each Domain

#### Example Configuration for angular.example.com
Create `nginx-frontend.conf`:
```nginx
server {
    listen 80;
    server_name angular.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
```

#### Example Configuration for flask.example.com
Create `nginx-backend.conf`:
```nginx
server {
    listen 80;
    server_name flask.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
```

### 3. Run Nginx Containers for Each Domain

#### Nginx Container for angular.example.com
```sh
$ docker run -d --name nginx-angular --network nginx-certbot-network -v $(pwd)/nginx-frontend.conf:/etc/nginx/conf.d/default.conf -v /var/www/certbot:/var/www/certbot -p 80:80 nginx
```

#### Nginx Container for flask.example.com
```sh
$ docker run -d --name nginx-flask --network nginx-certbot-network -v $(pwd)/nginx-backend.conf:/etc/nginx/conf.d/default.conf -v /var/www/certbot:/var/www/certbot -p 8080:80 nginx
```

### 4. Obtain Certificate

#### Obtain Certificate for angular.example.com:
```sh
$ docker run -it --rm --name certbot-angular -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot certbot/certbot certonly --webroot --webroot-path=/var/www/certbot --email youremail@example.com --agree-tos --no-eff-email -d angular.example.com
```

#### Obtain Certificate for flask.example.com:
```sh
$ docker run -it --rm --name certbot-flask -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot certbot/certbot certonly --webroot --webroot-path=/var/www/certbot --email youremail@example.com --agree-tos --no-eff-email -d flask.example.com
```

### 5. Certificate Location

- `/etc/letsencrypt/live/angular.example.com`
- `/etc/letsencrypt/live/flask.example.com`

## EC2 Instance:
```sh
$ docker login -u docker_hub_user_name
$ chmod 664 /var/run/docker.sock
$ newgrp docker

$ docker pull docker_hub_user_name/angular_app:latest
$ docker pull docker_hub_user_name/flask_app:latest
$ docker pull docker_hub_user_name/reverse-proxy:latest
```

Explanation: The Cloudflare Origin Certificates (origin.pem and origin.key) are already inside the image as specified by the COPY commands in the Dockerfile. 
Let’s Encrypt certificates are mapped as volumes because they are dynamically updated by Certbot and need to be reflected in the container.

## Deploying both Angular Standalone & Flask Standalone To EC2 with Origin Certificate and Cert-Bot Certificates.

### Using Docker Compose
```sh
$ touch docker-compose.yml
$ vi docker-compose.yml
```
Copy and paste the contents of `docker-compose.yml`, then:
```sh
$ docker-compose config --quiet && printf "OK\n" || printf "ERROR\n"
```
Proceed once only the message of the above commands outputs OK
```sh
$ docker-compose up -d
$ docker-compose ps
$ docker-compose down
```

### Without Using Docker-Compose


#### Pull The Images From Docker Hub To EC2 Instance
```sh
$ docker pull docker_hub_user_name/flask_app:latest
$ docker pull docker_hub_user_name/angular_app:latest
$ docker pull docker_hub_user_name/reverse-proxy:latest
```

#### Run the Containers One By One
```sh
$ docker run -d --name flask_app --network mynetwork -p 7080:80 -p 7443:443 -v /etc/letsencrypt/live/flask.example.com/fullchain.pem:/etc/letsencrypt/live/flask.example.com/fullchain.pem -v /etc/letsencrypt/live/flask.example.com/privkey.pem:/etc/letsencrypt/live/flask.example.com/privkey.pem -v /var/www/certbot:/var/www/certbot docker_hub_user_name/flask_app

$ docker run -d --name angular_app --network mynetwork -p 6080:80 -p 6443:443 -v /etc/letsencrypt/live/angular.example.com/fullchain.pem:/etc/letsencrypt/live/angular.example.com/fullchain.pem -v /etc/letsencrypt/live/angular.example.com/privkey.pem:/etc/letsencrypt/live/angular.example.com/privkey.pem -v /var/www/certbot:/var/www/certbot docker_hub_user_name/angular_app

$ docker run -d --name reverse-proxy --network mynetwork -p 80:80 -p 443:443 -v /etc/letsencrypt/live/flask.example.com/fullchain.pem:/etc/letsencrypt/live/flask.example.com/fullchain.pem -v /etc/letsencrypt/live/flask.example.com/privkey.pem:/etc/letsencrypt/live/flask.example.com/privkey.pem -v /etc/letsencrypt/live/angular.example.com/fullchain.pem:/etc/letsencrypt/live/angular.example.com/fullchain.pem -v /etc/letsencrypt/live/angular.example.com/privkey.pem:/etc/letsencrypt/live/angular.example.com/privkey.pem -v /var/www/certbot:/var/www/certbot reverse-proxy
```

#### Check The Status Of The Containers
```sh
$ docker ps -a
```

#### Stop Containers from Running
```sh
$ docker stop <container_id>
```

## Reboot EC2 Instance (Maybe required)

It was required for me to reboot the EC2 instance before I could access the paths from my browser.
Check the status of the containers after reboot and restart them.

```sh
$ docker restart $(docker ps -a -q)
```

## Additional Scripts (Can be used to avoid manual entry)

Local System (Linux)
```sh
$ chmod u+x build_images.sh
$ chmod u+x uild_tag_push.sh
```

EC2 Instance (Linux)
```sh
$ chmod u+x pull_images.sh
```
