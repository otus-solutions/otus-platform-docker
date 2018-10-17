# Docker Otus Plataform
## Dependencias
 - docker
 - docker-compose

 ## Passos para iniciar os containers
 Primeiramente, entre na pasta otus-plataform-compose pelo terminal.

 Execute o script:
 > sudo ./start.sh

Obs.: Avance as etapas de configuração, para deixar os valores padrão apenas clique ENTER.

## Deploy
- API
Execute o build informando o database.host=otus_db e após execute o deploy normalmente.

- Front-end
Copie o diretório completo da aplicação na pasta otus-plataform-compose/nginx/html/
Logo após restart o container
> sudo docker restart otus_frontend
