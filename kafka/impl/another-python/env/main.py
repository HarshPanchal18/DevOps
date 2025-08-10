import requests
import json
import time
import logging
from quixstreams import Application

def get_weather() -> requests.Response:
  return requests.get("https://api.open-meteo.com/v1/forecast", params={
    "latitude":51.5,
    "longitude":-0.11,
    "current":"temperature_2m",
  })

def main():
  app = Application(broker_address="localhost:9092", loglevel="DEBUG")

  with app.get_producer() as producer:

    while True:
      weather = get_weather()
      logging.debug("Got weather: %s", weather)
      producer.produce(
        topic = "weather-data-london",
        key   = "London",
        value = json.dumps(weather)
      )
      logging.info("Produced successfully")
      time.sleep(10)

if __name__ == "__main__":
  logging.basicConfig(level="DEBUG")
  main()