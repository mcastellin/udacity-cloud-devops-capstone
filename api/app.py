from flask import Flask
from flask.logging import create_logger
import logging
from prometheus_client import make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from werkzeug.serving import run_simple
from flask_prometheus_metrics import register_metrics

app = Flask(__name__)
LOG = create_logger(app)
LOG.setLevel(logging.INFO)


@app.route("/")
def home():
    html = "<h3>Auto scaling application test</h3>"
    return html.format(format)


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
