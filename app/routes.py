from flask import jsonify, render_template
from sqlalchemy.sql import text
from . import db

def register_routes(app):
    @app.route('/')
    def index():
        return render_template('index.html')

    @app.route('/api/coffee_stores')
    def api_coffee_stores():
        query = text("""
            SELECT p.name AS product_name, SUM(od.quantity) AS total_quantity
            FROM Products p
            JOIN OrderDetails od ON p.product_id = od.product_id
            GROUP BY p.name
            ORDER BY total_quantity DESC;
        """)
        result = db.session.execute(query)
        data = [{'name': row[0], 'quantity': row[1]} for row in result.fetchall()]
        return jsonify(data)

    @app.route('/api/employees')
    def api_employees():
        query = text("""
            SELECT 
                e.first_name + ' ' + e.last_name AS employee_name, 
                SUM(od.quantity) AS total_products
            FROM Employees e
            JOIN Orders o ON e.employee_id = o.employee_id
            JOIN OrderDetails od ON o.order_id = od.order_id
            GROUP BY e.employee_id, e.first_name, e.last_name
            ORDER BY total_products DESC;
        """)
        result = db.session.execute(query)
        data = [{'name': row[0], 'products': row[1]} for row in result.fetchall()]
        return jsonify(data)



