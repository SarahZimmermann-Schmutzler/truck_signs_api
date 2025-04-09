<div align="center">

![Truck Signs](./screenshots/Truck_Signs_logo.png)

# Containerization of a server application - Signs for Trucks

</div>

This guide describes:

* **how to containerize a REST API**
* **how to run database management systems (PostgreSQL) in containers**
* **how container communication works in networks**

It was created as part of my **DevSecOps training** at the Developer Akademie.

## Table of Contents

1. [Technologies](#technologies)
1. [Signs for Trucks](#signs-for-trucks---a-truck-signs-api)
1. [Screenshots of the Django Backend Admin Panel](#screenshots-of-the-django-backend-admin-panel)
1. [Quickstart](#quickstart)
1. [Usage](#usage)
   * [Installation and Preparation](#installation-and-preparation)
   * [Containerization with Docker](#containerization-with-docker)

## Technologies

* **Python** 3.8.10
  * **Django** 2.2.8 [More Information](https://www.djangoproject.com/)
    * It is a **web framework** for Python that helps you develop complex websites and web applications quickly and securely.
  * **Django Rest Framework** 3.12.4 [More Information](https://www.django-rest-framework.org/)
    * It is an extension of the Django framework that makes it easy to create flexible and powerful **web APIs using the REST standard**.
* **PostgreSQL** [More Information](https://www.postgresql.org/)
  * It is a powerful, object-relational, **open-source database management system** that securely stores, manages, and queries data.
* **Docker** 27.2.0 [More Information](https://www.docker.com/)
  * It is a platform that allows you to **isolate applications in containers** and run them reliably anywhere.

## Signs for Trucks - a Truck Signs Api

**Signs for Trucks** is an **backend application for an online store** to buy pre-designed vinyls with custom lines of letters (often call truck letterings). The store also allows clients to upload their own designs and to customize them on the website as well.  
  
Aside from the vinyls that are the main product of the store, clients can also purchase **simple lettering vinyls** with no truck logo, a fire extinguisher vinyl, and/or a vinyl with only the truck unit number (or another number selected by the client).  
  
It is **no frontend** given!

> [!Note]
> This project is based on an existing Django application that has been **adapted for containerization**. The **initial documentation** that contains further information about the application can be found [here](https://github.com/SarahZimmermann-Schmutzler/truck_signs_api/commit/af3969fedc9584d51201ee406abdc2ea677d278d#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5).

## Screenshots of the Django Backend Admin Panel

### Mobile View

![alt text](./screenshots/Admin_Panel_View_Mobile.png) ![alt text](./screenshots/Admin_Panel_View_Mobile_2.png)
![alt text](./screenshots/Admin_Panel_View_Mobile_3.png)

### Desktop View

![alt text](./screenshots/Admin_Panel_View.png)

![alt text](./screenshots/Admin_Panel_View_2.png)

![alt text](./screenshots/Admin_Panel_View_3.png)

## Quickstart

This section provides a fast and **minimal setup guide** for using the tools in this repository. For a more **in-depth understanding** and additional options, please refer to the [Usage](#usage) section.

1. Clone the repo e.g. using an SSH-Key:

    ```bash
    git clone git@github.com:SarahZimmermann-Schmutzler/truck_signs_api.git
    ```

1. Configure the **environment variables** like shown [here](#installation-and-preparation).

1. Build the **container image for the app-container** using the given Dockerfile:

    ```bash
    docker build -t truck_signs .
    ```

1. Create a **docker network** so that the app- and database-container can communicate:

    ```bash
    docker network create truck_signs_network
    ```

1. Run the **database-container**:

    ```bash
    docker run -d \
    --name truck_signs_db \ 
    --network truck_signs_network \ 
    --env-file ./truck_signs_designs/settings/.env \ 
    -v path/to/your/data-saving-folder:/var/lib/postgresql/data \
    --restart always \
    postgres:13
    ```

1. Run the **app-container**:

    ```bash
    docker run -d \
    --name truck_signs_web \
    --network truck_signs_network \
    --env-file ./truck_signs_designs/settings/.env \
    -v $(pwd):/app \
    -p 8020:5000 \
    --restart on-failure \
    truck_signs
    ```

1. Check if everything is fine:

    * Get a **list of all running Docker containers**. If there was no error while the starting processes, you should find the app- and database-container there:

        ```bash
        docker ps
        ```

      * <ins>If the status is `Up`</ins>:  
      The app should be running in **IP-Address_of_yor_Host:8020/admin**. You can log in there immediately with your superuser data that are defined in the .env.

      * <ins>If the status is not `Up`</ins>:  
      Have a look into the **logfiles**:  

        ```bash
        docker logs truck_signs_db  
        # or  
        docker logs truck_signs_web
        ```

## Usage

### Installation and Preparation

1. Clone the repo e.g. using an SSH-Key:

    ```bash
    git clone git@github.com:SarahZimmermann-Schmutzler/truck_signs_api.git
    ```

2. Configure the **environment variables**:

    * Create an `.env` file in [this](./truck_signs_designs/settings/) directory with the **variables shown below**:

        ```bash
        sudo nano .env
        ```

        ```bash
        # IP address of your VM for ALLOWED_HOSTS in truck_signs_designs > settings > base.py.
        IP_ADDRESS_VM=yourIpAddress
        SUPERUSER_USERNAME=yourSuperuserName
        SUPERUSER_EMAIL=yourSuperuserMail
        SUPERUSER_PASSWORD=yourSuperuserPassword
        SECRET_KEY=configSeeBelow
        DB_NAME=trucksigns_db
        DB_USER=trucksigns_user
        DB_PASSWORD=supertrucksignsuser!
        # If you don not want to name your database-container "truck_signs_db" you have to change the DB_HOST name also in the entrypoint.sh and the docker command to run the container.
        DB_HOST=truck_signs_db
        DB_PORT=5432
        STRIPE_PUBLISHABLE_KEY=forDevelopmentItCouldBeADummy
        STRIPE_SECRET_KEY=forDevelopmentItCouldBeADummy
        EMAIL_HOST_USER=forDevelopmentItCouldBeADummy
        EMAIL_HOST_PASSWORD=forDevelopmentItCouldBeADummy
        ```

    * The other variables from the [env example file](./truck_signs_designs/settings/simple_env_config.env) are not suitable for the purpose shown in this repository.

    * The `SECRET_KEY` is the django secret key.

      * To generate a new one have a look [here](https://stackoverflow.com/questions/41298963/is-there-a-function-for-generating-settings-secret-key-in-django)

    * **NOTE: Test data is required for testing purposes**
      * `STRIPE_PUBLISHABLE_KEY` and `STRIPE_SECRET_KEY`: The payment system [Stripe](https://stripe.com/) is prepared, but not connected.

      * `EMAIL_HOST_USER` and `EMAIL_HOST_PASSWORD`: This are the credentials to send emails from the website when a client makes a purchase. This is currently disable, but the code to activate this can be found in views.py in the create order view as comments. Therefore, any valid email and password will work.

### Containerization with Docker

1. Create a `.dockerignore` file with:

    ```bash
    .gitignore
    .git/
    __pycache__/
    ```

1. The [Dockerfile](./Dockerfile) is a text file that describes step by step how to build a Docker image – including the base image, installed software and configurations.

1. The [entrypoint.sh](./entrypoint.sh) is a script that is automatically executed when a Docker container is started and handles typical startup commands or initializations.

1. Build the **container image for the app-container** using the Dockerfile:  

    ```bash
    docker build -t truck_signs .
    ```

    * **-t** : This flag defines the name or tag of the container image.
    * **.** : The dot indicates that the build context directory is the current directory. Docker looks for the Dockerfile in this directory.

1. Create a **docker network** so that the app- and database-container can communicate:

    ```bash
    docker network create truck_signs_network
    ```

    * Display your docker networks to **check if the creation was successful**:

        ```bash
        docker network ls
        ```

    * Later you can display **which container is in the network** to check if they have **connected properly**:

        ```bash
        docker network inspect truck_signs_network
        ```  

1. Run the **database-container**:

    ```bash
    docker run -d \
    --name truck_signs_db \ 
    --network truck_signs_network \ 
    --env-file ./truck_signs_designs/settings/.env \ 
    -v path/to/your/data-saving-folder:/var/lib/postgresql/data \
    --restart always \
    postgres:13
    ```

    * **-d** : Starts container in detached mode (runs as background process and does not block the terminal).
    * **--name** : Names the container.
    * **--network** : Assigns the container to a network. You should use the one you created under 5.
    * **--env-file** : Path to the .env file where the environment variables are stored. In this projects it is in [truck_signs_designs > settings > .env](#installation-and-preparation).
    * **-v** : Bind-Mount for data persistence. Path to a directory on the host that stores the data from the database container to retain the data even if the container is deleted : path where the data ist stored on the database container.
    * **--restart always** : Ensures that the container restarts automatically. Often the best choice for a database container because it minimizes outages and ensures a reliable database connection for connected applications.
    * **postgres:13** : Official PostgreSQL Image, newest version.

1. Run the **app-container**:

    ```bash
    docker run -d \
    --name truck_signs_web \
    --network truck_signs_network \
    --env-file ./truck_signs_designs/settings/.env \
    -v $(pwd):/app \
    -p 8020:5000 \
    --restart on-failure \
    truck_signs
    ```

    * You can find the explanations for **-d** to **--env-file** above.
    * **-v $(pwd):/app** : Binds the the host's current working directory to the /app path in the container. This mirrors files and changes on the host directly into the container. This is helpful e.g. if you want to make code changes locally and see them immediately in the container.
    * **-p 8020:5000** : Publishes port 5000 of the container to port 8020 of the host. Applications on the host can access the container using localhost:8020 (or the host IP address), while the application within the container listens on port 5000.
    * **--restart on failure** : Specifies that the container only restarts if it exits with an error (exit code not 0).
    * **truck_signs** : The name of the Docker image used for the container.

1. Check if everything is fine:

    * Get a **list of all running Docker containers**. If there was no error while the starting processes, you should find the app- and database-container there:

        ```bash
        docker ps
        ```

        * <ins>If the status is `Up`</ins>:  
        The App should be running in **IP-Address_of_yor_Host:8020/admin**. You can log in there immediately with your superuser data that are defined in the .env.

        * <ins>If the status is not `Up`</ins>:  
        Have a look into the **logfiles**:

            ```bash
            docker logs truck_signs_db  
            # or  
            docker logs truck_signs_web
            ```

> [!NOTE]
> To create Truck vinyls with Truck logos in them, first create the **Category** Truck Sign, and then the **Product** (can have any name). This is to make sure the frontend retrieves the Truck vinyls for display in the Product Grid as it only fetches the products of the category Truck Sign.
