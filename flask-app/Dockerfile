FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app/hello.py ./

ENV FLASK_APP=hello.py

EXPOSE 5000

CMD [ "flask", "run", "--host=0.0.0.0" ]
