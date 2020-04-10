from flask import Flask, request, jsonify, render_template
from flask.logging import create_logger
from prometheus_client import make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from werkzeug.serving import run_simple
from flask_prometheus_metrics import register_metrics
import dateparser
import logging
import os

app = Flask(__name__)
LOG = create_logger(app)
LOG.setLevel(logging.INFO)

RELEASE = os.getenv("RELEASE", "undefined")

DEFAULT_FORMAT = "%Y-%m-%d %H:%M"


@app.route("/")
def index():
    """
    Renders the application html homepage
    """
    return render_template("index.html", release=RELEASE)


@app.route("/translate", methods=["POST"])
def translate():
    """Translates a time reference expressed in natural language into a python date object

    input looks like: 
    {
        "text": "the day before yesterday"
    }

    result will look like:
    {
        "result": "2020-04-10 22:10"
    }

    if the application cannot parse the input text a 404 status is returned
    """
    payload = request.json
    resolved_date = dateparser.parse(payload["text"])
    if resolved_date != None:
        return jsonify({"result": resolved_date.strftime(DEFAULT_FORMAT)})
    else:
        return jsonify({"status": "notFound"}), 404


@app.route("/health")
def health():
    html = "Application is healthy!"
    return html.format(format)


# provide app's version and deploy environment/config name to set a gauge metric
register_metrics(app, app_version="v0.1.1", app_config="production")

# Plug metrics WSGI app to your main app with dispatcher
dispatcher = DispatcherMiddleware(app.wsgi_app, {"/metrics": make_wsgi_app()})

if __name__ == "__main__":
    # app.run(host="0.0.0.0", port=8080, debug=True)
    run_simple(hostname="0.0.0.0", port=8080, application=dispatcher)
