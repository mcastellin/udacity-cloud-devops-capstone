from locust import HttpLocust, TaskSet, between

SAMPLE_REQUEST = {"text": "in three days"}


def index(l):
    l.client.get("/")


def translation(l):
    l.client.post("/translat", json=SAMPLE_REQUEST)


class DateTranslationLoadTesting(TaskSet):
    tasks = {index: 1, translation: 2}


class WebsiteUser(HttpLocust):
    task_set = DateTranslationLoadTesting
    wait_time = between(0, 9)
