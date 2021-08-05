FROM python:3

RUN pip install --no-cache-dir boto3

COPY . .

CMD [ "python", "./reduce.py" ]
