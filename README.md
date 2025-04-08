<div align="center">

![Truck Signs](./screenshots/Truck_Signs_logo.png)

# Signs for Trucks - Backend Application

![Python version](https://img.shields.io/badge/Pythn-3.8.10-4c566a?logo=python&&longCache=true&logoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django version](https://img.shields.io/badge/Django-2.2.8-4c566a?logo=django&&longCache=truelogoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django-RestFramework](https://img.shields.io/badge/Django_Rest_Framework-3.12.4-red.svg?longCache=true&style=flat-square&logo=django&logoColor=white&colorA=4c566a&colorB=pink)

</div>

## Table of Contents

* [Description](#description)
* [Quickstart](#quickstart)
* [Usage](#usage)
  * [Installation and Preparation](#installation-and-preparation)
  * [Containerization with Docker](#containerization-with-docker)
* [Screenshots of the Django Backend Admin Panel](#screenshots)
* [Useful Links](#useful_links)

## Description

__Signs for Trucks__ is an backend application for an online store to buy pre-designed vinyls with custom lines of letters (often call truck letterings). The store also allows clients to upload their own designs and to customize them on the website as well. Aside from the vinyls that are the main product of the store, clients can also purchase simple lettering vinyls with no truck logo, a fire extinguisher vinyl, and/or a vinyl with only the truck unit number (or another number selected by the client).
It is no frontend given!

### Settings

The __settings__ folder inside the trucks_signs_designs folder contains the different setting's configuration for each environment (so far the environments are development, docker testing, and production). Those files are extensions of the base.py file which contains the basic configuration shared among the different environments (for example, the value of the template directory location). In addition, the .env file inside this folder has the environment variables that are mostly sensitive information and should always be configured before use. By **default**, the environment in use is the **development environment**. To change between environments modify the \_\_init.py\_\_ file.

### Models

Most of the models do what can be inferred from their name. The following dots are notes about some of the models to make clearer their propose:
- __Category Model:__ The category of the vinyls in the store. It contains the title of the category as well as the basic properties shared among products that belong to a same category. For example, _Truck Logo_ is a category for all vinyls that has a logo of a truck plus some lines of letterings (note that the vinyls are instances of the model _Product_). Another category is _Fire Extinguisher_, that is for all vinyls that has a logo of a fire extinguisher. 
- __Lettering Item Category:__ This is the category of the lettering, for example: _Company Name_, _VIM NUMBER_, ... Each has a different pricing.
- __Lettering Item Variations:__ This contains a foreign key to the __Lettering Item Category__ and the text added by the client.
- __Product Variation:__ This model has the original product as a foreign key, plus the lettering lines (instances of the __Lettering Item Variations__ model) added by the client.
- __Order:__ Contains the cart (in this case the cart is just a vinyl as only one product can be purchased each time). It also contains the contact and shipping information of the client.
- __Payment:__ It has the payment information such as the time of the purchase and the client id in Stripe.

To manage the payments, the payment gateway in use is [Stripe](https://stripe.com/).

### Brief Explanation of the Views

Most of the views are CBV imported from _rest_framework.generics_, and they allow the backend api to do the basic CRUD operations expected, and so they inherit from the _ListAPIView_, _CreateAPIView_, _RetrieveAPIView_, ..., and so on.

The behavior of some of the views had to be modified to address functionalities such as creation of order and payment, as in this case, for example, both functionalities are implemented in the same view, and so a _GenericAPIView_ was the view from which it inherits. Another example of this is the _UploadCustomerImage_ View that takes the vinyl template uploaded by the clients and creates a new product based on it.

## Quickstart

This section provides a fast and **minimal setup guide** for using the tools in this repository. For a more **in-depth understanding** and additional options, please refer to the [Usage](#usage) section.

1. Clone the repo e.g. using an SSH-Key:

    ```bash
    git clone git@github.com:SarahZimmermann-Schmutzler/truck_signs_api.git
    ```

1. Configure the **environment variables** like shown [here](#installation-and-preparation).

1. Build the **Container-Image for the App-Container** using the given Dockerfile:

    ```bash
    docker build -t truck_signs .
    ```

1. Create a **docker network** so that the App- and Database-Container can communicate:

    ```bash
    docker network create truck_signs_network
    ```

1. Run the **Database-Container**:

    ```bash
    docker run -d \
    --name truck_signs_db \ 
    --network truck_signs_network \ 
    --env-file ./truck_signs_designs/settings/.env \ 
    -v path/to/your/data-saving-folder:/var/lib/postgresql/data \
    --restart always \
    postgres:13
    ```

1. Run the **App-Container**:

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

1. Is everything fine?

* Get a **list of all running Docker containers**. If there was no error while the starting processes, you should find the app- and database-container there:

    ```bash
    docker ps
    ```

  * <ins>If the status is `Up`</ins>:  
    The App should be running in IP-Address_of_yor_Host:8020 - But you know, there is no frontend, so have a look at the admin-panel page: **IP-Address_of_yor_Host:8020/admin**. You can log in there immediately with your superuser data that are defined in the .env.

  * <ins>If the status is not `Up`</ins>:  
    Have a look into the **logfiles** and do a little debugging:  

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

    * Copy the content of the **example env file** that is inside the truck_signs_designs folder into a `.env file`:

    ```bash
    cd truck_signs_designs/settings
    cp simple_env_config.env .env
    sudo nano .env
    ```

    * The new `.env file` should contain all the environment variables necessary to run all the django app in all the environments. However, the only needed variables for the **development environment** to run are the following:

    ```bash
    IP_ADDRESS_VM=yourIpAddress
    # There is an env-variable for your IP-Address in the Allowed-Hosts-Section in truck_signs_designs > settings > base.py. 
    # If you do not need it then earase it there and here.
    SUPERUSER_USERNAME=yourSuperuserName
    SUPERUSER_EMAIL=yourSuperuserMail
    SUPERUSER_PASSWORD=yourSuperuserPassword
    SECRET_KEY=configSeeBelow
    DB_NAME=trucksigns_db
    DB_USER=trucksigns_user
    DB_PASSWORD=supertrucksignsuser!
    # If you don not want to name your database-container "truck_signs_db" you have to change the host name also in the entrypoint.sh.
    DB_HOST=truck_signs_db
    DB_PORT=5432
    STRIPE_PUBLISHABLE_KEY=forDevelopmentItCouldBeADummy
    STRIPE_SECRET_KEY=forDevelopmentItCouldBeADummy
    EMAIL_HOST_USER=forDevelopmentItCouldBeADummy
    EMAIL_HOST_PASSWORD=forDevelopmentItCouldBeADummy
    ```

    * The `SECRET_KEY` is the django secret key

      * To generate a new one see: [Stackoverflow Link](https://stackoverflow.com/questions/41298963/is-there-a-function-for-generating-settings-secret-key-in-django)

    * **NOTE: not required for exercise**
      * The `STRIPE_PUBLISHABLE_KEY` and the `STRIPE_SECRET_KEY` can be obtained from a developer account in [Stripe](https://stripe.com/).
        * To retrieve the keys from a Stripe developer account follow the next instructions:
            1. Log in into your Stripe developer account (stripe.com) or create a new one (stripe.com > Sign Up). This should redirect to the account's Dashboard.
            2. Go to Developer > API Keys, and copy both the Publishable Key and the Secret Key.

    * The `EMAIL_HOST_USER` and the `EMAIL_HOST_PASSWORD` are the credentials to send emails from the website when a client makes a purchase. This is currently disable, but the code to activate this can be found in views.py in the create order view as comments. Therefore, any valid email and password will work.

### Containerization with Docker

1. If you work with **Docker** you need a `.dockerignore-file` for:

    ```bash
    .gitignore
    .git/
    __pycache__/
    ```

2. The [Dockerfile](./Dockerfile) is a text file that describes step by step how to build a Docker image – including the base image, installed software and configurations.

3. The [entrypoint.sh](./entrypoint.sh) is a script that is automatically executed when a Docker container is started and handles typical startup commands or initializations.

4. Build the **Container-Image for the App-Container** using the Dockerfile:  

    ```bash
    docker build -t truck_signs .
    ```

    * *-t*: This flag defines the name or tag of the container image.
    * *.*: The dot indicates that the build context directory is the current directory. Docker looks for the Dockerfile in this directory.

5. Create a **docker network** so that the App- and Database-Container can communicate:

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

6. Run the **Database-Container**:

    ```bash
    docker run -d \
    --name truck_signs_db \ 
    --network truck_signs_network \ 
    --env-file ./truck_signs_designs/settings/.env \ 
    -v path/to/your/data-saving-folder:/var/lib/postgresql/data \
    --restart always \
    postgres:13
    ```

    * *-d*: Starts container in detached mode (runs as background process and does not block the terminal).
    * *--name*: Names the container.
    * *--network*: Assigns the container to a network. You should use the one you created under 5.
    * *--env-file*: Path to the .env file where the environment variables are stored. In this projects it is in [truck_signs_designs > settings > .ev](#installation-and-preparation).
    * *-v*: Bind-Mount for data persistence. Path to a directory on the host that stores the data from the database container to retain the data even if the container is deleted : path where the data ist stored on the database container.
    * *--restart always*: Ensures that the container restarts automatically. Often the best choice for a database container because it minimizes outages and ensures a reliable database connection for connected applications.
    * *postgres:13*: Official PostgreSQL Image, newest version.

7. Run the **App-Container**:

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

    * You can find the explanation for *-d* to *--env-file* is under 6.
    * *-v $(pwd):/app* : Binds the the host's current working directory to the /app path in the container. This mirrors files and changes on the host directly into the container. This is helpful e.g. if you want to make code changes locally and see them immediately in the container.
    * *-p 8020:5000* : Publishes port 5000 of the container to port 8020 of the host. Applications on the host can access the container using localhost:8020 (or the host IP address), while the application within the container listens on port 5000.
    * *--restart on failure* : Specifies that the container only restarts if it exits with an error (exit code not 0).
    * *truck_signs* : The name of the Docker image used for the container.

8. Is everything fine?

    * Get a **list of all running Docker containers**. If there was no error while the starting processes, you should find the app- and database-container there:

        ```bash
        docker ps
        ```

        * <ins>If the status is `Up`</ins>:  
        The App should be running in IP-Address_of_yor_Host:8020 - But you know, there is no frontend, so have a look at the admin-panel page: **IP-Address_of_yor_Host:8020/admin**. You can log in there immediately with your superuser data that are defined in the .env.

        * <ins>If the status is not `Up`</ins>:  
        Have a look into the **logfiles** and do a little debugging:

        ```bash
        docker logs truck_signs_db  
        # or  
        docker logs truck_signs_web
        ```

__NOTE:__ To create Truck vinyls with Truck logos in them, first create the __Category__ Truck Sign, and then the __Product__ (can have any name). This is to make sure the frontend retrieves the Truck vinyls for display in the Product Grid as it only fetches the products of the category Truck Sign.

---

<a name="screenshots"></a>

## Screenshots of the Django Backend Admin Panel

### Mobile View

<div align="center">

![alt text](./screenshots/Admin_Panel_View_Mobile.png)  ![alt text](./screenshots/Admin_Panel_View_Mobile_2.png) ![alt text](./screenshots/Admin_Panel_View_Mobile_3.png)

</div>
---

### Desktop View

![alt text](./screenshots/Admin_Panel_View.png)

---

![alt text](./screenshots/Admin_Panel_View_2.png)

---

![alt text](./screenshots/Admin_Panel_View_3.png)


<a name="useful_links"></a>
## Useful Links

### Postgresql Database
- Setup Database: [Digital Ocean Link for Django Deployment on VPS](https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-16-04)

### Docker
- [Docker Oficial Documentation](https://docs.docker.com/)
- Dockerizing Django, PostgreSQL, guinicorn, and Nginx:
    - Github repo of sunilale0: [Link](https://github.com/sunilale0/django-postgresql-gunicorn-nginx-dockerized/blob/master/README.md#nginx)
    - Michael Herman article on testdriven.io: [Link](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)

### Django and DRF
- [Django Official Documentation](https://docs.djangoproject.com/en/4.0/)
- Generate a new secret key: [Stackoverflow Link](https://stackoverflow.com/questions/41298963/is-there-a-function-for-generating-settings-secret-key-in-django)
- Modify the Django Admin:
    - Small modifications (add searching, columns, ...): [Link](https://realpython.com/customize-django-admin-python/)
    - Modify Templates and css: [Link from Medium](https://medium.com/@brianmayrose/django-step-9-180d04a4152c)
- [Django Rest Framework Official Documentation](https://www.django-rest-framework.org/)
- More about Nested Serializers: [Stackoverflow Link](https://stackoverflow.com/questions/51182823/django-rest-framework-nested-serializers)
- More about GenericViews: [Testdriver.io Link](https://testdriven.io/blog/drf-views-part-2/)

### Miscellaneous
- Create Virual Environment with Virtualenv and Virtualenvwrapper: [Link](https://docs.python-guide.org/dev/virtualenvs/)
- [Configure CORS](https://www.stackhawk.com/blog/django-cors-guide/)
- [Setup Django with Cloudinary](https://cloudinary.com/documentation/django_integration)
