# Versão da imagem que será utilizada
FROM python:3.9-alpine3.13
# Mantenedor do projeto
LABEL mainteiner="JpHy"

ENV PYTHONUNBUFFERED 1

# Copia o requirements local para o docker, o app, define o diretório de trabalho e qual porta será utilizada
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
# Jamais rodar a aplicação usando o root user

# Caminho da variável de ambiente
ENV PATH="/py/bin:$PATH"

USER django-user