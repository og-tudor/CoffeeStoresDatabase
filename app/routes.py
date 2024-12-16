from flask import jsonify, render_template
from sqlalchemy.sql import text
from . import db

def register_routes(app):
    # Route for index page
    @app.route('/')
    def index():
        return render_template('index.html')

    # Route for Coffee Stores page
    @app.route('/coffee_stores')
    def coffee_stores():
        return render_template('coffee_stores.html', title="Coffee Stores")

    # API for Coffee Stores data
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

    # Route for Employees page
    @app.route('/employees')
    def employees():
        return render_template('employees.html', title="Employees")

    # API for Employees data
    @app.route('/api/employees')
    def api_employees():
        query = text("""
            SELECT 
                CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
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

    # Statistic 1 API for Coffee Stores Revenue
    @app.route('/api/statistic1', methods=['GET'])
    def statistic1():
        query = text("EXEC GetCoffeeStoresRevenue")
        result = db.session.execute(query)
        data = [{"Cafea": row[0], "Oras": row[1], "Obiectiv_Venit": row[2]} for row in result.fetchall()]
        return jsonify(data)
