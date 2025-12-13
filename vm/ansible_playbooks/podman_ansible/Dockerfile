FROM python:3.12-alpine

RUN pip install --no-cache-dir ansible
WORKDIR /ansible
ENTRYPOINT ["ansible", "--version"]