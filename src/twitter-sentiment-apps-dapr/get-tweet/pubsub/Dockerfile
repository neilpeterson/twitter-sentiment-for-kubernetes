FROM python

RUN pip install tweepy && \
    pip install DaprClient

ADD ./get-tweet.py /app/get-tweet.py

ENTRYPOINT ["python", "/app/get-tweet.py"]