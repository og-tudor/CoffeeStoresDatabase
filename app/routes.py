from flask import jsonify, render_template, request
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
        data = [{"Chain": row[0], "City": row[1], "RevenueGoal": row[2], "Manager": row[3]} for row in result.fetchall()]
        return jsonify(data)

    @app.route('/api/coffee_stores_list', methods=['GET'])
    def coffee_stores_list():
        query = text("EXECUTE GetCoffeeStores;")
        result = db.session.execute(query)
        data = [{'id': row[0], 'name': row[1]} for row in result.fetchall()]
        return jsonify(data)


    @app.route('/api/coffee_store_details/<int:store_id>/<int:month>/<int:year>', methods=['GET'])
    def coffee_store_details(store_id, month, year):
        query = text("EXEC GetCoffeeStoreDetails @store_id = :store_id, @month = :month, @year = :year")
        result = db.session.execute(query, {'store_id': store_id, 'month': month, 'year': year}).fetchone()

        if result:
            data = {
                'name': result[0],
                'city': result[1],
                'revenue_goal': result[2],
                'manager': result[3],
                'top_product': result[4] if result[4] else "No data",
                'total_revenue': result[5] if result[5] else 0,
            }
            return jsonify(data)
        else:
            return jsonify({'error': 'Store not found'}), 404

    @app.route('/api/monthly_sales_expenses', methods=['GET'])
    def monthly_sales_expenses():
        # Get parameters from query string
        store_id = request.args.get('store_id')
        year = request.args.get('year')

        # Validate inputs
        if not store_id or not year:
            return jsonify({'error': 'store_id and year are required'}), 400

        try:
            # Execute the procedure with parameters
            query = text("""
                EXEC GetMonthlySalesAndExpenses @store_id = :store_id, @year = :year
            """)
            result = db.session.execute(query, {'store_id': store_id, 'year': year}).fetchall()

            # Process the data into a JSON response
            data = [{
                'store_name': row[0],
                'month': row[1],
                'year': row[2],
                'monthly_revenue': float(row[3]) if row[3] else 0,
                'monthly_expenses': float(row[4]) if row[4] else 0
            } for row in result]

            return jsonify(data)

        except Exception as e:
            return jsonify({'error': str(e)}), 500