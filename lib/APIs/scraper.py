from flask import Flask, request, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import requests
import re
import time

app = Flask(__name__)

@app.route('/fetchImg', methods = ['get'])
def fetchImg():
    options = Options()
    options.headless = True
    driver = webdriver.Chrome('D:\Program Files\Chromedriver\chromedriver.exe', options=options)
    url = str(request.args['query'])
    driver.get(url)
    time.sleep(2)

    html = driver.page_source
    soup = BeautifulSoup(html, 'lxml')

    images = []
    result = {}
    image_elements = soup.find_all('img', class_='page-img')

    for element in image_elements:
        image_url = element['src']
        images.append(image_url)

    result['images'] = images
    driver.quit()
    return jsonify(result)

@app.route('/search', methods = ['get'])
def search():
    url = f"https://bato.to/search?word={str(request.args['query'])}"
    r = requests.get(url)
    time.sleep(5)
    print(r.status_code)
    soup = BeautifulSoup(r.content, 'lxml')

    result = []
    l = soup.find('div', id='series-list')
    # print(l)
    items = l.find_all('div', class_='col item line-b no-flag')

    for item in items:
        res = {}
        res['cover'] = item.find('a', class_='item-cover').find('img')['src']
        i = item.find('a', class_='item-title')
        link = i['href']
        res['link'] = f"https://bato.to{link}"
        title = i.text
        title = re.sub("<.*?>", "", title);
        res['title'] = title
        result.append(res)

    items = l.find_all('div', class_='col item line-b')

    for item in items:
        res = {}
        res['cover'] = item.find('a', class_='item-cover').find('img')['src']
        i = item.find('a', class_='item-title')
        link = i['href']
        res['link'] = f"https://bato.to{link}"
        title = i.text
        title = re.sub("<.*?>", "", title);
        res['title'] = title
        result.append(res)

    return jsonify(result)

@app.route('/latest', methods = ['get'])
def latest():
    url = f"https://bato.to/"
    r = requests.get(url)
    time.sleep(5)
    print(r.status_code)
    soup = BeautifulSoup(r.content, 'lxml')

    result = []
    l = soup.find('div', id='series-list')
    items = l.find_all('div', recursive=False)

    for item in items:
        res = {}
        res['cover'] = item.find('a', class_='item-cover').find('img')['src']
        i = item.find('a', class_='item-title')
        link = i['href']
        res['link'] = f"https://bato.to{link}"
        title = i.text
        title = re.sub("<.*?>", "", title);
        res['title'] = title
        result.append(res)

    return jsonify(result)


if __name__ == "__main__":
  app.run(host='0.0.0.0', port=5000, debug=True)