FROM python:3.7-slim
LABEL maintainer="manuel@castellinconsulting.com"

ENV RELEASE="undefined"

# Creating non-root user for application to run
RUN mkdir -p /home/capstone &&\
        groupadd -r capstone -g 999 &&\
        useradd -u 999 -g capstone -d /home/capstone -s /sbin/nologin -c "Capstone user" capstone &&\
        chown -R 999:999 /home/capstone 

COPY --chown=999:999 . /opt/api/
WORKDIR /opt/api/

# hadolint ignore=DL3013
RUN pip install --upgrade pip &&\
        pip install -r requirements.txt

USER capstone

EXPOSE 8080

CMD ["python", "app.py"]
