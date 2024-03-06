FROM python

RUN pip install azure-servicebus

ADD ./moc-get-tweet.py /app/moc-get-tweet.py
ADD ./tweet-body.json /app/tweet-body.json

ENTRYPOINT ["python", "/app/moc-get-tweet.py"]