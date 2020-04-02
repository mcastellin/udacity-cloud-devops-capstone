from flask import Flask
from flask.logging import create_logger
import logging

app = Flask(__name__)
LOG = create_logger(app)
LOG.setLevel(logging.INFO)


@app.route("/")
def home():
    html = "<h3>Auto scaling application</h3>"
    LOG.debug("rendering homepage...")
    return html.format(format)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)
