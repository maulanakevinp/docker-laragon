<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpOFdvSMFGIcIlIhqKU2AYPv5m3WDP3gCvxw&s" alt="Project logo"></a>
</p>

<h3 align="center">Docker Laragon WSL</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/maulanakevinp/docker-laragon.svg)](https://github.com/maulanakevinp/docker-laragon/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/maulanakevinp/docker-laragon.svg)](https://github.com/maulanakevinp/docker-laragon/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> Few lines describing your project.
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Built Using](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>
Docker Laragon is a modern alternative to Laragon, powered by Docker containers. Before getting started, make sure Docker is installed on your Windows to unlock seamless cross-platform development.

## 🏁 Getting Started <a name = "getting_started"></a>

Before you begin, make sure Docker is installed on your Windows. Docker Laragon runs seamlessly inside Docker containers. With Docker, you unlock a portable, consistent, and hassle-free development experience. Get ready to supercharge your workflow!

### Prerequisites

- Download and install Docker from the official website: [Docker Installation](https://docs.docker.com/get-docker/).
- Install Docker Compose by following the official guide: [Docker Compose Installation](https://docs.docker.com/compose/install/).
- Install WSL (Windows Subsystem for Linux) if you use Windows by following the official guide: [WSL Installation](https://docs.microsoft.com/en-us/windows/wsl/install).
- Install Ubuntu with WSL. Open your terminal and follow these commands:
```
wsl --install -d Ubuntu
```
- Ensure you have a code editor installed, such as Visual Studio Code or any other of your choice.
- Familiarity with Docker and Docker Compose is recommended

### Installing

Follow these steps to install Docker Laragon:
1. Open Your Ubuntu terminal (WSL) with Run as Administrator
```
- Search Ubuntu in taskbar Windows
- Click Run as Administrator
```

2. Clone the docker-laragon:

```
git clone https://github.com/maulanakevinp/docker-laragon.git 
```

3. Navigate to the project directory:

```
cd docker-laragon
```

4. Run the Docker Compose command to start the containers:

```
docker-compose up -d
```

## 🎈 Usage <a name="usage"></a>

To add a new project, follow these steps:

1. Create a new directory for your project inside the `../public_html` folder:

```
mkdir ../public_html
```

2. Navigate to the new project directory:

```
cd ../public_html
```

3. Clone your laravel projects inside the `public_html`:

```
git clone https://github.com/your-username/your-project.git
```

4. Navigate to your project directory:

```
cd your-project
```

5. Setup your environment
6. Install the project dependencies go to inside container php first:

```
docker exec -it php82 bash
```
```
cd your-project
```
```
composer update
```
```
exit
```

7. Create domain + ssl. 

```
cd ~/docker-laragon
```

8. Run the following command to create a new domain and SSL certificate:

```
./add-domain-ssl.sh
```

9. Your project should now be accessible via the domain you created.

## ⛏️ Built Using <a name = "built_using"></a>

- [Docker](https://www.docker.com/) - The container platform used for development
- [Docker Compose](https://docs.docker.com/compose/) - Tool for defining and running multi-container Docker applications
- [Nginx](https://www.nginx.com/) - Web server and reverse proxy
- [PHP](https://www.php.net/) - Server-side scripting language (php-8.0|8.1|8.2)
- [Composer](https://getcomposer.org/) - Dependency Manager for PHP
- [MySQL](https://www.mysql.com/) - Database Management System
- [phpMyAdmin](https://www.phpmyadmin.net/) - Database Administration Tool
- [Mailhog](https://github.com/mailhog/MailHog) - Email testing tool

## ✍️ Authors <a name = "authors"></a>

- [@maulanakevinp](https://github.com/maulanakevinp) - Idea & Initial work

See also the list of [contributors](https://github.com/maulanakevinp/docker-laragon/contributors) who participated in this project.

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Hat tip to anyone whose code was used
- Inspiration
- References
