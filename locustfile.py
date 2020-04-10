from locust import HttpLocust, TaskSet, between

def index(l):
    l.client.get("/")

class PredictionLoadTesting(TaskSet):
    tasks = {index: 1}


class WebsiteUser(HttpLocust):
    task_set = PredictionLoadTesting
    wait_time = between(0, 1)
