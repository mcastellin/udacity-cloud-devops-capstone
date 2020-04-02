FROM python:3.7-stretch
LABEL maintainer="manuel@castellinconsulting.com"

COPY . /opt/api/

WORKDIR /opt/api/

# hadolint ignore=DL3013
RUN pip install --upgrade pip &&\
        pip install -r requirements.txt

EXPOSE 80

CMD ["python", "app.py"]
