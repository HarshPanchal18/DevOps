from flask import Flask, request, abort

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.method == 'POST':
        print(request.json)
        return 'ok', 200
    else:
        abort(400)

@app.route('/webhook1', methods=['POST'])
def webhook1():
    if request.method == 'POST':
        print(request.json)
        return 'ok', 200
    else:
        abort(400)

if __name__ == '__main__':
    app.run()