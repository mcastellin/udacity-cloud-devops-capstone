from datetime import datetime, timedelta
import unittest
import json
import app


class TestTranslationApi(unittest.TestCase):
    def setUp(self):
        self.app = app.app.test_client()
        self.app.Testing = True

    def test_get_homepage(self):
        response = self.app.get("/")
        self.assertEqual(response.status_code, 200)

    def test_translate_date(self):
        expected_date = datetime.today() + timedelta(days=1)

        response = self.app.post(
            "/translate",
            data=json.dumps({"text": "tomorrow"}),
            content_type="application/json",
        )
        data = json.loads(response.get_data())
        result = data["result"]

        self.assertEqual(response.status_code, 200)
        assert result != None

        returned_date = datetime.strptime(result, app.DEFAULT_FORMAT)
        assert returned_date.date() == expected_date.date()


if __name__ == "__main__":
    unittest.main()
