from flask import Flask
from api.api_routes import api_bp
from admin.admin_routes import admin_bp

app = Flask(__name__)
app.register_blueprint(api_bp, url_prefix='/api')
app.register_blueprint(admin_bp, url_prefix='/admin')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
