from flask import Flask
app = Flask(__name__)

@app.route('/')
def message():
    return '<h1>Application is running</h1>'

if __name__ == "__main__":
    app.run(debug=True)