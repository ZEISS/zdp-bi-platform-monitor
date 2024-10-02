from flask import Flask, request
import requests
from waitress import serve

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, I am alive!'

@app.route('/api/alerts', methods = ['POST'])
def receive_alert():
    alert = request.get_json()
    esb_api_url = 'https://esb.zeiss.com/public/api/mail/'
    payload = '''{ "Subject": "Prometheus Alert", "MessageBodyPlainText": "Welcome to the ZEISSGlobal Plain Text Mail API.", "Priority": "High", "Recipients": ["stefan.pohl@zeiss.com"], "From": "zdp-afi@zeiss.com",
                "Sender": "ZDP-AFI Platform Team",
                "ReplyTo": "kush.kashyap@zeiss.com",
                "ErrorReportDetails": false,
                "SaveAttachmentsExternal": false}'''
    headers = {'Content-type': 'application/json', 'Cache-Control': 'no-cache', 'EsbApi-Subscription-Key' : '93b12e82a8264d4594026388c6c664a1'}
    
    try:
        r = requests.post(esb_api_url, data=payload, headers=headers)
        print("Return Code: " + str(r.status_code))
    except requests.ConnectionError:
        print("Failed to connect to ESB API")    
    
    return '', 204

if __name__ == '__main__':
    # app.run(host = '0.0.0.0', port=5000)
    serve(app, host="0.0.0.0", port=9082)