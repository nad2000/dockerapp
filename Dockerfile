FROM python:3.5
RUN pip install Flask==0.11.1 redis==2.10.5
RUN useradd -ms /bin/bash admin
USER admin
# we cannot use volumes in VM / cloud VM
COPY app /app
WORKDIR /app
CMD ["python", "app.py"] 
